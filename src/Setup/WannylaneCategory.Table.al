namespace Wanamics.Wannylane.Setup;

using Wanamics.Wannylane.Request;
#if AppSource
table 71544436
#else
table 87436
#endif
"Wannylane Category Proxy"
{
    Caption = 'Wannylane Category';
    DataClassification = ToBeClassified;
    LookupPageId = "Wannylane Categories";
    TableType = Temporary;
    // DataPerCompany = false;

    fields
    {
        field(1; id; BigInteger)
        {
            Caption = 'Id';
            ToolTip = 'Specifies the value of the Id field.', Comment = '%';
            DataClassification = CustomerContent;
        }
        field(2; label; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the value of the Name field.', Comment = '%';
            DataClassification = CustomerContent;
        }
        field(3; direction; Text[20])
        {
            Caption = 'DIrection';
            ToolTip = 'Specifies the value of the Direction field.', Comment = '%';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
    procedure Load()
    var
        WannylaneHelper: Codeunit "Wannylane Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        WannylaneHelper.Load(RecordRef, '/categories');
        //TODO Category Group
    end;
}
