namespace WannyLane.WannyLane;
using Wanamics.Wannylane.Request;

page 87437 "Wannylane Proxy Generator"
{
    ApplicationArea = All;
    Caption = 'Wannylane Proxy Generator';
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Resource; Resource)
                {
                    Caption = 'Resource';
                    ToolTip = 'Resource';
                }
                field(RepeaterToken; RepeaterToken)
                {
                    Caption = 'Repeater Token';
                    ToolTip = 'Repeater Token';
                }
                field(PrimaryKeyFieldName; PrimaryKeyFieldName)
                {
                    Caption = 'Primary Key Field Name';
                    ToolTip = 'Primary Key Field Name';
                }
                field(TableNo; TableNo)
                {
                    Caption = 'Table No.';
                    ToolTip = 'Table No.';
                }
                field(PageNo; PageNo)
                {
                    Caption = 'Page No.';
                    ToolTip = 'Page No.';
                }

            }
            group(Responses)
            {
                // grid(Grid1)
                // {
                //     GridLayout = Columns;
                field(ProxyTable; ProxyTable.ToText())
                {
                    Caption = 'Proxy Table';
                    ToolTip = 'Proxy Table';
                    MultiLine = true;
                }
                field(ProxyPage; ProxyPage.ToText())
                {
                    Caption = 'Proxy Page';
                    ToolTip = 'Proxy Page';
                    MultiLine = true;
                }
                // }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SendRequest)
            {
                Caption = 'Send request';
                Image = ExecuteBatch;
                trigger OnAction()
                var
                    Request: Codeunit "Wannylane Request";
                    jToken: JsonToken;
                    jArray: JsonArray;
                    jObject: JsonObject;
                    // Values : List of [JsonValue];
                    jTokens: List of [JsonToken];
                    jValue: JsonValue;
                // i: Integer;
                // t: Text;
                begin
                    Request.GET(Resource).SelectToken(RepeaterToken, jToken);
                    jArray := jToken.AsArray();
                    if jArray.Count = 0 then
                        Error('%1 %2 array is Empty', Resource, RepeaterToken);

                    if not jArray.Get(0, jToken) then
                        error('Get(0)');
                    GenerateHeader(Resource, TableNo, PageNo);
                    jToken.AsObject().SelectTokens('.*', jTokens);
                    foreach jToken in jTokens do
                        if jToken.IsValue then
                            GenerateLine(jToken.AsValue())
                        else if jToken.IsObject then
                            if jToken.AsObject().Get(PrimaryKeyFieldName, jToken) and jToken.IsValue then
                                GenerateLine(jToken.AsValue());
                    GenerateFooter(Resource, PrimaryKeyFieldName);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Resource := '/supplier_invoices';
        RepeaterToken := 'items';
        PrimaryKeyFieldName := 'id';
        TableNo := 87449;
        PageNo := 87449;
    end;

    var
        Resource: Text;
        RepeaterToken: Text;
        // Response: Text;
        ProxyTable: TextBuilder;
        ProxyPage: TextBuilder;
        FieldId: Integer;
        PrimaryKeyFieldName: Text;
        TableNo: Integer;
        PageNo: Integer;

    local procedure GenerateHeader(pResource: Text; pTableNo: Integer; pPageNo: Integer)
    begin
        ProxyTable.AppendLine('table ' + format(pTableNo) + ' "' + pResource + ' Proxy"');
        ProxyTable.AppendLine('{');
        // ProxyTable.AppendLine('//    Caption = ''' + pResource + ''';');
        ProxyTable.AppendLine('    DataClassification = SystemMetadata;');
        ProxyTable.AppendLine('    TableType = Temporary;');
        ProxyTable.AppendLine('    fields');
        ProxyTable.AppendLine('    {');

        ProxyPage.AppendLine('page ' + format(pPageNo) + ' "' + pResource + '"');
        ProxyPage.AppendLine('{');
        ProxyPage.AppendLine('    ApplicationArea = All;');
        ProxyPage.AppendLine('    UsageCategory = None;');
        ProxyPage.AppendLine('    PageType = List;');
        ProxyPage.AppendLine('    SourceTable = "' + pResource + ' Proxy";');
        ProxyPage.AppendLine('    Editable = false;');
        ProxyPage.AppendLine('    ');
        ProxyPage.AppendLine('    layout');
        ProxyPage.AppendLine('    {');
        ProxyPage.AppendLine('        area(Content)');
        ProxyPage.AppendLine('        {');
        ProxyPage.AppendLine('            repeater(General)');
        ProxyPage.AppendLine('            {');
    end;

    local procedure GenerateLine(jValue: JsonValue)
    begin
        if jValue.IsNull then
            GenerateLine(jValue.Path.Substring(Strlen(RepeaterToken + '[0].') + 1), 'IsNull')
        else
            GenerateLine(jValue.Path.Substring(Strlen(RepeaterToken + '[0].') + 1), jValue.AsText());
    end;

    local procedure GenerateLine(pName: Text; pValue: Text)
    begin
        FieldId += 1;
        ProxyTable.AppendLine('        field(' + format(FieldId) + '; "' + pName + '"; ' + FieldType(pValue) + ') { }');
        ProxyPage.AppendLine('                field("' + pName + '"; Rec."' + pName + '") { }');
    end;

    local procedure FieldType(pValue: Text): Text
    var
        AsDate: Date;
        AsDateTime: DateTime;
        AsBigInteger: BigInteger;
        AsDecimal: Decimal;
        AsBoolean: Boolean;
    begin
        if pValue = 'IsNull' then
            exit(pValue);
        if Evaluate(AsDate, pValue, 9) then
            exit('Date');
        if Evaluate(AsDateTime, pValue, 9) then
            exit('DateTime');
        if Evaluate(AsBoolean, pValue, 9) then
            exit('Boolean');
        if Evaluate(AsDecimal, pValue, 9) and pValue.Contains('.') then
            exit('Decimal');
        if Evaluate(AsBigInteger, pValue, 9) then
            exit('BigInteger');
        exit('Text[' + format(Strlen(pValue)) + ']');
    end;

    local procedure GenerateFooter(pResource: Text; pPKFieldName: Text)
    begin
        ProxyTable.AppendLine('    }');
        ProxyTable.AppendLine('    keys');
        ProxyTable.AppendLine('    {');
        ProxyTable.AppendLine('        key(PK; ' + pPKFieldName + ')');
        ProxyTable.AppendLine('        {');
        ProxyTable.AppendLine('            Clustered = true;');
        ProxyTable.AppendLine('        }');
        ProxyTable.AppendLine('    }');
        ProxyTable.AppendLine('    ');
        ProxyTable.AppendLine('    procedure Load()');
        ProxyTable.AppendLine('    var');
        ProxyTable.AppendLine('        Helper: Codeunit "API Helper";');
        ProxyTable.AppendLine('        RecordRef: RecordRef;');
        ProxyTable.AppendLine('    begin');
        ProxyTable.AppendLine('        RecordRef.GetTable(Rec);');
        ProxyTable.AppendLine('        Helper.Load(RecordRef, ''' + pResource + ''');');
        ProxyTable.AppendLine('    end;');
        ProxyTable.AppendLine('}');

        ProxyPage.AppendLine('            }');
        ProxyPage.AppendLine('        }');
        ProxyPage.AppendLine('    }');
        ProxyPage.AppendLine('    trigger OnOpenPage()');
        ProxyPage.AppendLine('    begin');
        ProxyPage.AppendLine('        Rec.Load();');
        ProxyPage.AppendLine('    end;');
        ProxyPage.AppendLine('}');
    end;
}
