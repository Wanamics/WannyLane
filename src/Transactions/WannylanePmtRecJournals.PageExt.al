namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Reconciliation;
#if AppSource
pageextension 71544430
#else
pageextension 87430
#endif
"Wannylane Pmt. Rec. Journals" extends "Pmt. Reconciliation Journals"
{
    layout
    {
        addafter("Bank Account No.")
        {
            field(WannylaneBankAccountName; Rec."Bank Account Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Bank Account Name';
                DrillDown = false;
            }
        }
        addafter("Statement No.")
        {
            field(WannylaneStatementDate; Rec."Statement Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Statement Date';
            }
            field(WannylaneNoOfLines; WannylaneGetNoOfLines())
            {
                Caption = 'No. of Lines';
                ToolTip = 'Specifies No. of Lines';
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addfirst(Process)
        {
            action(WannylaneTransactionsToNew)
            {
                Caption = 'Import Pennylane Transactions';
                ToolTip = 'Import Pennylane Transactions';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Wannylane Trans. to Reconcile");
                end;
            }
        }
        addfirst(Category_Process)
        {
            actionref(WannylaneTransactionsToNew_Promoted; WannylaneTransactionsToNew) { }
        }
    }
    local procedure WannylaneGetNoOfLines(): Integer
    var
        BancAccReconcilisationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BancAccReconcilisationLine.SetRange("Statement Type", Rec."Statement Type");
        BancAccReconcilisationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BancAccReconcilisationLine.SetRange("Statement No.", Rec."Statement No.");
        exit(BancAccReconcilisationLine.Count());
    end;
}
