namespace Wanamics.Wannylane.Connect;
using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Request;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Setup;
table 87431 "Wannylane Bank Account Proxy"
{
    Caption = 'Wannylane Bank Account';
    DataClassification = ToBeClassified;
    LookupPageId = "Wannylane Bank Accounts";
    // DataPerCompany = false;
    TableType = Temporary;

    fields
    {
        field(1; id; BigInteger)
        {
            Caption = 'Id';
            ToolTip = 'Specifies the value of the Id field.';
            Width = 10;
            DataClassification = AccountData;
        }
        field(2; name; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the value of the Name field.';
            DataClassification = AccountData;
        }
        field(9; currency; Code[10])
        {
            Caption = 'Currency Code', Locked = true;
            ToolTip = 'Specifies the value of the Currency Code field.';
            Width = 3;
            DataClassification = SystemMetadata;
        }
        field(4; balance; Decimal)
        {
            Caption = 'Balance';
            DataClassification = AccountData;
        }
        field(5; created_at; DateTime)
        {
            Caption = 'Updated at', Locked = true;
            DataClassification = SystemMetadata;
        }
        field(6; updated_at; DateTime)
        {
            Caption = 'Updated at', Locked = true;
            DataClassification = SystemMetadata;
        }
        // field(15; iban; Code[50])
        // {
        //     Caption = 'IBAN';
        //     ToolTip = 'Specifies the value of the IBAN field.';
        //     Width = 25;
        //     DataClassification = AccountData;
        // }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        // fieldgroup(DropDown; id, name, iban) { }
    }
    procedure Load()
    var
        WannylaneHelper: Codeunit "Wannylane Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        WannylaneHelper.Load(RecordRef, '/bank_accounts');
    end;

    procedure GetBankAccount() ReturnValue: Record "Bank Account"
    begin
        ReturnValue.SetRange("Wannylane Bank Account ID", Rec.id);
        if ReturnValue.FindFirst() then;
    end;

    procedure CreateBankAccount(var pBankAccount: Record "Bank Account")
    var
        GLSetup: Record "General Ledger Setup";
        NoSeries: Codeunit "No. Series";
    begin
        GLSetup.Get();
        NoSeries.TestManual(GLSetup."Bank Account Nos."); // TODO : Could be 5120..5129 then create GLAccount and BankAccoutPostingGroup
        CheckAlreadyLinked();
        pBankAccount.Init();
        pBankAccount."No." := '';
        pBankAccount.Validate(Name, CopyStr(name, 1, MaxStrLen(pBankAccount.Name)));
        pBankAccount.Validate("Last Payment Statement No.", '0000');
        // pBankAccount.Validate(IBAN, IBAN); //TODO : How to get IBAN from Pennylane ?
        if Rec.currency = GLSetup."LCY Code" then
            pBankAccount."Currency Code" := ''
        else
            pBankAccount.Validate("Currency Code", currency);
        pBankAccount.Insert(true);
    end;

    local procedure CheckAlreadyLinked(): Boolean
    var
        BankAccount: Record "Bank Account";
        AlreadyLinkedErr: Label 'already linked';
    begin
        BankAccount.SetRange("Wannylane Bank Account ID", Rec.id);
        if BankAccount.FindFirst() then
            BankAccount.FieldError("Bank Account No.", AlreadyLinkedErr);
    end;
}
