namespace Wanamics.Wannylane.Setup;

using Wanamics.Wannylane.Connect;

table 87430 "Wannylane Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'Wannylane Setup';
    // DataPerCompany = false;
    fields
    {
        field(1; "PK"; Code[10])
        {
            Caption = 'PK', Locked = true;
            ToolTip = 'PK', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
            ToolTip = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(10; "Base Address"; Text[150])
        {
            Caption = 'Base URL';
            ToolTip = 'Base URL';
            DataClassification = SystemMetadata;
            InitValue = 'https://app.Pennylane.com/api/external/v2';
        }
    }

    keys
    {
        key(PK; "PK")
        {
            Clustered = true;
        }
    }

    procedure ResetDefault()
    begin
        Init();
        Modify(true);
    end;

    procedure Initialize()
    var
        WannylaneCategory: Record "Wannylane Category Proxy";
        InProgress: Dialog;
        InProgressLbl: Label 'Initializing #1############################', Comment = '%1:Step (TableCaption)';
    begin
        Init();
        Enabled := true;
        Modify(true);
        InProgress.Open(InProgressLbl);
        InProgress.Update(1, WannylaneCategory.TableCaption);
        WannylaneCategory.Load();
        InProgress.Close();
    end;

    trigger OnInsert()
    begin
        DeleteSecrets();
    end;

    trigger OnDelete()
    begin
        DeleteSecrets();
    end;

    local procedure DeleteSecrets()
    begin
        DeleteSecret(true);
        DeleteSecret(false);
    end;

    procedure DeleteSecret(SandboxMode: Boolean)
    begin
        if IsolatedStorage.Contains(WannylaneSecretTok, DataScope::Company) then
            IsolatedStorage.Delete(WannylaneSecretTok, DataScope::Company);
    end;

    procedure StoreSecret(Secret: SecretText)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(WannylaneSecretTok, Secret, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(WannylaneSecretTok, Secret, DataScope::Company);
    end;

    internal procedure SetKeysIfAvailable(var Secret: Text)
    begin
        if IsolatedStorage.Contains(WannylaneSecretTok, DataScope::Company) then
            Secret := '****';
    end;

    internal procedure GetSecret(var Secret: SecretText) ReturnValue: Boolean
    var
        SecretIsEmptyErr: Label 'Secret is empty';
    begin
        ReturnValue := IsolatedStorage.Get(WannylaneSecretTok, DataScope::Company, Secret);
        if GuiAllowed then
            if Secret.IsEmpty() then
                Error(SecretIsEmptyErr);
        exit;
    end;

    var
        WannylaneSecretTok: Label 'WannylaneSecret', Locked = true;
}
