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
        field(10; "Base Endpoint"; Text[150])
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
        DeleteApiKeys();
    end;

    trigger OnDelete()
    begin
        DeleteApiKeys();
    end;

    local procedure DeleteApiKeys()
    begin
        DeleteApiKey(true);
        DeleteApiKey(false);
    end;

    procedure DeleteApiKey(SandboxMode: Boolean)
    begin
        if IsolatedStorage.Contains(WannylaneApiKeyTok, DataScope::Company) then
            IsolatedStorage.Delete(WannylaneApiKeyTok, DataScope::Company);
    end;

    procedure StoreApiKey(ApiKey: SecretText)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(WannylaneApiKeyTok, ApiKey, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(WannylaneApiKeyTok, ApiKey, DataScope::Company);
    end;

    internal procedure SetKeysIfAvailable(var ApiKey: Text)
    begin
        if IsolatedStorage.Contains(WannylaneApiKeyTok, DataScope::Company) then
            ApiKey := '****';
    end;

    internal procedure GetApiKey(var ApiKey: SecretText) ReturnValue: Boolean
    var
        ApiKeyIsEmptyErr: Label 'Apikey is empty';
    begin
        ReturnValue := IsolatedStorage.Get(WannylaneApiKeyTok, DataScope::Company, ApiKey);
        if GuiAllowed then
            if ApiKey.IsEmpty() then
                Error(ApiKeyIsEmptyErr);
        exit;
    end;

    var
        WannylaneApiKeyTok: Label 'WannylaneApiKey', Locked = true;
}
