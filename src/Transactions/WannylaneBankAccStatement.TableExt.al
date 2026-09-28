namespace Wanamics.Wannylane.Transactions;

using Microsoft.Bank.Statement;

#if AppSource
tableextension 71544432
#else
tableextension 87432
#endif
"Wannylane Bank Acc. Statement" extends "Bank Account Statement"
{
    fields
    {
#if AppSource
        field(71544430;
#else
        field(87430;
#endif
        "Wannylane Timestamp"; DateTime)
        {
            Caption = 'Wannylane Timestamp';
            ToolTip = 'Wannylane Timestamp';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
}
