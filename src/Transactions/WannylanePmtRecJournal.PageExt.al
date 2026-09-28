namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;
using Wannylane.Wannylane.Transactions;

pageextension 87431 "Wannylane Pmt. Rec. Journal" extends "Payment Reconciliation Journal"
{
    layout
    {
        modify("Transaction Date") { Editable = not WannylaneReconciliation; }
        // modify("Transaction Text") { Editable = not WannylaneReconciliation; }
        modify("Statement Amount") { Editable = not WannylaneReconciliation; }
        moveafter("Account No."; AccountName)
        modify("Shortcut Dimension 1 Code") { Visible = false; }
        modify("Shortcut Dimension 2 Code") { Visible = false; }
    }
    actions
    {
        addlast(processing)
        {
            action(WannylaneSplitLine)
            {
                ApplicationArea = All;
                Caption = 'Split Line';
                ToolTip = 'Split Line';
                Image = Split;
                trigger OnAction()
                var
                    WannylanePmtRecBankSplit: Page "Wannylane Pmt. Rec. Split";
                begin
                    Rec.TestField("Applied Amount", 0);
                    WannylanePmtRecBankSplit.SetRecord(Rec);
                    if WannylanePmtRecBankSplit.RunModal() = Action::OK then
                        WannylanePmtRecBankSplit.Split();
                end;
            }
            action(WannylaneMergeWithNext)
            {
                ApplicationArea = All;
                Caption = 'Merge with Next';
                ToolTip = 'Merge with Next';

                Image = Undo;
                trigger OnAction()
                var
                    WannylanePmtRecBankSplit: Page "Wannylane Pmt. Rec. Split";
                begin
                    WannylanePmtRecBankSplit.SetRecord(Rec);
                    WannylanePmtRecBankSplit.Merge();
                end;
            }
            // movelast(Category_Process; ApplyEntries_Promoted);
        }
    }
    var
        WannylaneReconciliation: Boolean;

    trigger OnOpenPage()
    var
        BancAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        BancAccReconciliation.Get(Rec.GetRangeMax("Statement Type"), Rec.GetRangeMax("Bank Account No."), Rec.GetRangeMax("Statement No."));
        WannylaneReconciliation := BancAccReconciliation.Wannylane(); //."Wannylane Timestamp" <> 0DT;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        WannylaneDisallowed();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        WannylaneDisallowed();
    end;

    local procedure WannylaneDisallowed()
    var
        DisallowedErr: Label 'Wannylane Statement lines are not editable';
    begin
        if WannylaneReconciliation then
            Error(DisallowedErr);
    end;
}
