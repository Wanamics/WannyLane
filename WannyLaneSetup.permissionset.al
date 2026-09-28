namespace Wanamics.Wannylane;

using Wanamics.Wannylane.Setup;
using Wanamics.Wannylane.Connect;
using Wanamics.Wannylane.Transactions;
using Wanamics.Wannylane.Request;

permissionset 87430 Wannylane_SETUP
{
    Caption = 'Wannylane Setup';
    Assignable = true;
    Permissions =
        tabledata "Wannylane Bank Account Proxy" = RIMD,
        tabledata "Wannylane Bank Establ. Proxy" = RIMD,
        tabledata "Wannylane Category Proxy" = RIMD,
        tabledata "Wannylane Setup" = RIMD,
        table "Wannylane Bank Account Proxy" = X,
        table "Wannylane Bank Establ. Proxy" = X,
        table "Wannylane Category Proxy" = X,
        table "Wannylane Setup" = X,
        codeunit "Wannylane Request" = X,
        codeunit "Wannylane Bank Rec. Events" = X,
        codeunit "Wannylane Helper" = X,
        codeunit "Wannylane Setup Events" = X,
        // codeunit "Wannylane Trans. to Reconcile" = X,
        page "Wannylane Bank Accounts" = X,
        page "Wannylane Bank Establishments" = X,
        page "Wannylane Categories" = X,
        // page "Wannylane Items" = X,
        page "Wannylane Setup" = X,
        page "Wannylane Transaction Preview" = X;
    // page "Wannylane Bank Hub Accounts" = X;
}