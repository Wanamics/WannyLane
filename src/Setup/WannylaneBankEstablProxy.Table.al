namespace Wanamics.Wannylane.Setup;

using Wanamics.Wannylane.Request;
table 87435 "Wannylane Bank Establ. Proxy"
{
    Caption = 'Wannylane Bank Establishment';
    DataClassification = ToBeClassified;
    LookupPageId = "Wannylane Bank Establishments";
    // DataPerCompany = false;
    TableType = Temporary;

    fields
    {
        field(1; id; BigInteger)
        {
            Caption = 'Id';
            ToolTip = 'Specifies the value of the Id field.', Comment = '%';
            DataClassification = CustomerContent;
        }
        field(2; name; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the value of the Name field.', Comment = '%';
            DataClassification = CustomerContent;
        }
        // field(3; parent_name; Text[50])
        // {
        //     Caption = 'Parent Name';
        //     ToolTip = 'Specifies the value of the Parent Name field.', Comment = '%';
        //     DataClassification = CustomerContent;
        // }
        // field(4; country_code; Code[10])
        // {
        //     Caption = 'Country Code', Locked = true;
        //     ToolTip = 'Specifies the value of the Country Code field.', Comment = '%';
        //     DataClassification = CustomerContent;
        // }
        // field(7; logo_url; Text[100])
        // {
        //     Caption = 'Logo URL';
        //     ToolTip = 'Specifies the value of the Logo URL field.', Comment = '%';
        //     DataClassification = CustomerContent;
        // }
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
        WannylaneHelper.Load(RecordRef, '/bank_establishments');
    end;
}
