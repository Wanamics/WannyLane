namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Statement;

codeunit 87433 "Wannylane Trans. to Reconcile"
{
    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        WannylaneTransactionProxy: Record "Wannylane Transaction Proxy";
        Added: Integer;
        DateWarningLbl: Label 'Warning : %1 (day before Workdate) will be used as transactions filter.', Comment = '%1: WorkDate';
        ContinueLbl: Label 'Do you want to continue?';
        ConfirmLbl: Label 'Do you want to create "%1" from "%2" for %3 "%4"?', Comment = '%1: BankAccReconciliation.TableCaption, %2:WannylaneAccount.TableCaption, %3:Count, %4:BankAccount.TableCaption';
        DoneLbl: Label '%1 "%2" created', Comment = '%1: Nb.of, %2: BankAccReconciliation TableCaption';
        IsLast: Boolean;
    begin
        if WorkDate() <> Today() then
            if not Confirm(DateWarningLbl + '\' + ContinueLbl, false, WorkDate() - 1) then
                exit;
        if GuiAllowed then
            if not Confirm(ConfirmLbl, false, BankAccReconciliation.TableCaption, WannylaneTransactionProxy.TableCaption, BankAccount.Count, BankAccount.TableCaption) then
                exit;
        BankAccount.SetFilter("Wannylane Bank Account ID", '<>0');
        if BankAccount.FindSet() then
            repeat
                if NewBankAccReconciliation(BankAccount) then
                    Added += 1;
            until BankAccount.Next() = 0;
        if GuiAllowed then
            Message(DoneLbl, Added, BankAccReconciliation.TableCaption);
    end;


    local procedure NewBankAccReconciliation(pBankAccount: Record "Bank Account") IsEmpty: Boolean
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Rec: Record "Wannylane Transaction Proxy";
    begin
        Rec.Load(pBankAccount."Wannylane Bank Account ID", LastStatementDate(pBankAccount) + 1);
        if not Rec.FindSet() then
            exit(true);
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation."Statement No." := '';
        BankAccReconciliation.Validate("Bank Account No.", pBankAccount."No.");
        BankAccReconciliation."Statement Ending Balance" := StatementStartingBalance(pBankAccount);
        BankAccReconciliation.Insert(true);
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        BankAccReconciliationLine."Statement Line No." := 0;
        repeat
            BankAccReconciliationLine.Init();
            BankAccReconciliationLine."Statement Line No." += 10000;
            BankAccReconciliationLine.Validate("Transaction Date", Rec.date);
            // BankAccReconciliationLine.Validate("Value Date", pRec.value_date);
            BankAccReconciliationLine.Validate("Transaction Text", CopyStr(Rec.label, 1, MaxStrLen(BankAccReconciliationLine."Transaction Text")));
            BankAccReconciliationLine.Validate("Statement Amount", Rec.amount);
            BankAccReconciliationLine.Insert(true);
            if BankAccReconciliationLine."Transaction Date" > BankAccReconciliation."Statement Date" then
                BankAccReconciliation."Statement Date" := BankAccReconciliationLine."Transaction Date";
            BankAccReconciliation."Statement Ending Balance" += Rec.amount;
        until Rec.Next() = 0;
        BankAccReconciliation.Validate("Statement Date");
        BankAccReconciliation.Validate("Statement Ending Balance");
        BankAccReconciliation."Wannylane Timestamp" := Rec.updated_at;
        BankAccReconciliation.Modify(true);
        if not pBankAccount."Disable Automatic Pmt Matching" then
            Codeunit.Run(Codeunit::"Match Bank Pmt. Appl.", BankAccReconciliation);
    end;

    local procedure StatementStartingBalance(pBankAccount: Record "Bank Account"): Decimal
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.SetCurrentKey("Statement Type", "Bank Account No.", "Statement No.");
        BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        BankAccReconciliation.SetRange("Bank Account No.", pBankAccount."No.");
        if BankAccReconciliation.FindLast() then
            exit(BankAccReconciliation."Statement Ending Balance")
        else
            exit(pBankAccount."Balance Last Statement");
    end;

    procedure LastStatementDate(pBankAccount: Record "Bank Account"): Date
    var
        BankAccountStatement: Record "Bank Account Statement";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.SetCurrentKey("Bank Account No.", "Statement Date");
        BankAccReconciliation.SetRange("Bank Account No.", pBankAccount."No.");
        if BankAccReconciliation.FindLast() then begin
            BankAccReconciliation.TestField("Statement Date");
            exit(BankAccReconciliation."Statement Date");
        end;
        BankAccountStatement.SetCurrentKey("Bank Account No.", "Statement Date");
        BankAccountStatement.SetRange("Bank Account No.", pBankAccount."No.");
        if BankAccountStatement.FindLast() then begin
            BankAccountStatement.TestField("Statement Date");
            exit(BankAccountStatement."Statement Date");
        end;
        exit(20000101D);
    end;
}
