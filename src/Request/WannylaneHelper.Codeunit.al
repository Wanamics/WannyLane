namespace Wanamics.Wannylane.Request;
codeunit 87434 "Wannylane Helper"
{
    procedure TokenToRecRef(pToken: JsonToken; pRecRef: RecordRef)
    var
        FldRef: FieldRef;
        i: Integer;
        Text: Text;
        Token: JsonToken;
        Guid: Guid;
    begin
        for i := 1 to pRecRef.FieldCount do begin
            FldRef := pRecRef.FieldIndex(i);
            if FldRef.Name[1] in ['a' .. 'z'] then
                if pToken.SelectToken('$.' + FldRef.Name, Token) and not Token.AsValue().IsNull then
                    case FldRef.Type of
                        FldRef.Type::BigInteger:
                            FldRef.Validate(Token.AsValue().AsBigInteger());
                        FldRef.Type::Boolean:
                            FldRef.Validate(Token.AsValue().AsBoolean());
                        FldRef.Type::Date:
                            FldRef.Validate(Token.AsValue().AsDate());
                        FldRef.Type::DateTime:
                            FldRef.Validate(Token.AsValue().AsDateTime());
                        FldRef.Type::Decimal:
                            FldRef.Validate(Token.AsValue().AsDecimal());
                        FldRef.Type::Guid:
                            begin
                                Text := Token.AsValue().AsText();
                                Evaluate(Guid, Text);
                                FldRef.Validate(Guid);
                            end;
                        FldRef.Type::Integer:
                            FldRef.Validate(Token.AsValue().AsInteger());
                        FldRef.Type::Option:
                            FldRef.Validate(OrdinalValue(Token.AsValue().AsText(), FldRef.OptionMembers));
                        FldRef.Type::Code,
                        FldRef.Type::Text:
                            begin
                                Text := Token.AsValue().AsText();
                                if StrLen(Text) > FldRef.Length then
                                    Text := Text.Substring(1, FldRef.Length);
                                FldRef.Validate(Text)
                            end;
                        FldRef.Type::Time:
                            FldRef.Validate(Token.AsValue().AsTime());
                    end;
        end;
    end;

    local procedure OrdinalValue(pText: Text; pOptionMembers: Text): Integer
    var
        Members: List of [Text];
    begin
        Members := pOptionMembers.Split(',');
        exit(Members.IndexOf(pText) - 1);
    end;

    procedure Load(var pRecordRef: RecordRef; pRequest: Text; pPagination: Integer)
    begin
        if pRequest.Contains('?') then
            pRequest += '&'
        else
            pRequest += '?';
        Load(pRecordRef, pRequest + StrSubstNo('limit=%1', pPagination));
    end;

    procedure Load(var pRecordRef: RecordRef; pRequest: Text)
    var
        WannylaneRequest: Codeunit "Wannylane Request";
        ResponseToken: JsonToken;
        jToken: JsonToken;
        jItem: JsonToken;
        jArray: JsonArray;
        jObject: JsonObject;
        Cursor: Text;
    // MustBeTemporaryErr: Label '%1 must be temporary.', Comment = '%1:TableCaption';
    begin
        // if not pRecordRef.IsTemporary then
        //     Error(MustBeTemporaryErr, pRecordRef.Caption);
        pRecordRef.Reset();
        pRecordRef.DeleteAll(true);
        repeat
            ResponseToken := WannylaneRequest.GET(pRequest + Cursor);
            ResponseToken.SelectToken('items', jToken);
            jArray := jToken.AsArray();

            foreach jItem in jArray do begin
                pRecordRef.Init();
                TokenToRecRef(jItem, pRecordRef);
                if pRecordRef.Insert(true) then;
            end;

            ResponseToken.SelectToken('next_cursor', jToken);
            if jToken.AsValue().IsNull then
                exit;
            if pRequest.Contains('?') then
                Cursor := '&'
            else
                Cursor := '?';
            Cursor += 'cursor=' + jToken.AsValue().AsText();
        until pRequest = '';
    end;
}
