namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;

#if AppSource
codeunit 71544435
#else
codeunit 87435
#endif
"Wannylane Bank Rec. Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation Line", OnBeforeValidateEvent, 'Account No.', false, false)]
    local procedure OnBeforeValidateAccountNo(var Rec: Record "Bank Acc. Reconciliation Line"; var xRec: Record "Bank Acc. Reconciliation Line"; CurrFieldNo: Integer)
    var
        CantBeBankAccountNoErr: Label 'can''t be the statement one';
    begin
        if (CurrFieldNo = Rec.Fieldno("Account No.")) and (Rec."Account Type" = Rec."Account Type"::"Bank Account") and (Rec."Account No." = Rec."Bank Account No.") then
            Rec.FieldError("Account No.", CantBeBankAccountNoErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", OnBeforePost, '', false, false)]
    local procedure OnBeforePost(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        CannotBeLaterThanLbl: Label 'cannot be later than %1.', Comment = '%1: FieldCaption("Statement Date")';
    begin
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetFilter("Transaction Date", '>%1', BankAccReconciliation."Statement Date");
        if BankAccReconciliationLine.FindFirst() then
            BankAccReconciliationLine.FieldError("Transaction Date", StrSubstNo(CannotBeLaterThanLbl, BankAccReconciliation.FieldCaption("Statement Date")));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "Bank Acc. Reconciliation"; RunTrigger: Boolean)
    var
        lRec: Record "Bank Acc. Reconciliation";
        MustBeTheLastOneErr: Label 'must be the last one for this bank account';
    begin
        //20251002 if Rec.IsTemporary or (Rec."Statement Date" = 0D) then
        if Rec.IsTemporary or (Rec."Statement Date" = 0D) or not RunTrigger then
            exit;
        lRec.SetRange("Statement Type", Rec."Statement Type");
        lRec.SetRange("Bank Account No.", Rec."Bank Account No.");
        lRec.SetFilter("Statement Date", '>%1', Rec."Statement Date");
        if not lRec.IsEmpty then
            Rec.FieldError("Statement Date", MustBeTheLastOneErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Recon. Post (Yes/No)", OnBeforeBankAccReconPostYesNo, '', false, false)]
    local procedure OnBeforeBankAccReconPostYesNo(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var Result: Boolean; var Handled: Boolean)
    var
        lRec: Record "Bank Acc. Reconciliation";
        MustBeTheFirstOneErr: Label 'must be the first one for this bank account';
    begin
        if BankAccReconciliation.IsTemporary or (BankAccReconciliation."Statement Date" = 0D) then
            exit;
        lRec.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        lRec.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        lRec.SetFilter("Statement Date", '<%1', BankAccReconciliation."Statement Date");
        if not lRec.IsEmpty then
            BankAccReconciliation.FieldError("Statement Date", MustBeTheFirstOneErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", OnInsertRecordEvent, '', false, false)]
    local procedure OnInsertPaymentRecLine(var Rec: Record "Bank Acc. Reconciliation Line")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.Get(Rec."Statement Type", Rec."Bank Account No.", Rec."Statement No.");
        BankAccReconciliation.TestField("Wannylane Timestamp", 0DT);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", OnDeleteRecordEvent, '', false, false)]
    local procedure OnDeletePaymentRecLine(var Rec: Record "Bank Acc. Reconciliation Line")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BankAccReconciliation.Get(Rec."Statement Type", Rec."Bank Account No.", Rec."Statement No.");
        BankAccReconciliation.TestField("Wannylane Timestamp", 0DT);
    end;
}
