namespace Wanamics.Wannylane.Connect;
using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Request;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Setup;
#if AppSource
table 71544431 "Wannylane Bank Account"
#else
table 87431 "Wannylane Bank Account Proxy"
#endif
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
        field(15; iban; Code[50])
        {
            Caption = 'IBAN';
            ToolTip = 'Specifies the value of the IBAN field.';
            Width = 25;
            DataClassification = AccountData;
        }
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
        fieldgroup(DropDown; id, name, iban) { }
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
        pBankAccount.Validate(IBAN, IBAN); //TODO : How to get IBAN from Pennylane ?
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
        // TestField(name);
        // BankAccount.SetRange("Bank Account No.", CopyStr(ExtractBankCardNumber(name, BankAccount.Name), 1, MaxStrLen(BankAccount."Bank Account No.")));
        BankAccount.SetRange("Wannylane Bank Account ID", Rec.id);
        if BankAccount.FindFirst() then
            BankAccount.FieldError("Bank Account No.", AlreadyLinkedErr);
    end;

    // local procedure ExtractBankCardNumber(pText: Text; var pBankAccountName: Text[100]) ReturnValue: Text
    // var
    //     Tokens: list of [Text];
    //     i, j : Integer;
    // begin
    //     Tokens := pText.Split();
    //     for i := 1 to Tokens.Count do
    //         if DelChr(Tokens.Get(i), '=', '0123456789') <> Tokens.Get(i) then begin
    //             ReturnValue := Tokens.Get(i);
    //             if Tokens.Count > 1 then
    //                 Tokens.RemoveAt(i);
    //             pBankAccountName := CopyStr(Tokens.Get(1), 1, MaxStrLen(pBankAccountName));
    //             for j := 2 to Tokens.Count do
    //                 pBankAccountName += ' ' + Tokens.Get(j);
    //             exit;
    //         end;
    // end;

    // procedure GetId(pBankAccount: Record "Bank Account"): BigInteger
    // begin
    //     Reset();
    //     if pBankAccount.IBAN <> '' then begin
    //         SetRange(iban, DelChr(pBankAccount.IBAN));
    //         if FindFirst() then
    //             exit(id);
    //     end else
    //         if pBankAccount."Bank Account No." <> '' then begin
    //             SetFilter(name, '*' + pBankAccount."Bank Account No." + '*');
    //             if FindFirst() then
    //                 exit(id);
    //         end;
    //     if pBankAccount.Name <> '' then begin
    //         SetFilter(name, '@*' + pBankAccount.Name + '*');
    //         if FindFirst() then
    //             exit(id);
    //     end;
    // end;
}
