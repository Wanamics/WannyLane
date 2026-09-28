namespace Wannylane.Wannylane.Setup;

using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Setup;

#if AppSource
pageextension 71544434
#else
pageextension 87434
#endif
"Wannylane Bank Account List" extends "Bank Account List"
{
    layout
    {
        addlast(Control1)
        {
            field("Wannylane Bank Account ID"; Rec."Wannylane Bank Account ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Wannylane Bank Account ID field.', Comment = '%';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(WannylaneSetup)
            {
                ApplicationArea = All;
                Caption = 'Wannylane Setup';
                ToolTip = 'Setup Pennylane Connexion';
                Image = Setup;
                RunObject = Page "Wannylane Setup";
            }
        }
        addlast(Promoted)
        {
            actionref(WannylaneSetup_Promoted; WannylaneSetup) { }
        }
    }
}
