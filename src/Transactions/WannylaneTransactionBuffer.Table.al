namespace Wanamics.Wannylane.Transactions;
using Microsoft.Bank.BankAccount;
using Wanamics.Wannylane.Connect;
using Wanamics.Wannylane.Request;
#if AppSource
table 71544432
#else
table 87432
#endif
"Wannylane Transaction Proxy"
{
    Caption = 'Wannylane Transaction';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; id; BigInteger)
        {
            Caption = 'id', Locked = true;
            ToolTip = 'id', Locked = true;
        }
        field(2; amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'amount', Locked = true;
        }
        //   "archived_at": null,
        //   "attachment_required": true,
        //   "created_at": "2026-09-25T13:48:55.574792Z",
        field(3; currency_amount; Decimal)
        {
            Caption = 'Currency Amount';
            ToolTip = 'currency_amount', Locked = true;
        }
        field(4; currency_fee; Decimal)
        {
            Caption = 'Currency Fee';
            ToolTip = 'currency_fee', Locked = true;
        }
        field(5; currency; Code[10])
        {
            Caption = 'Currency';
            ToolTip = 'currency', Locked = true;
        }
        field(6; "date"; Date)
        {
            Caption = 'Date';
            ToolTip = 'date', Locked = true;
        }
        field(7; fee; Decimal)
        {
            Caption = 'Fee';
            ToolTip = 'fee', Locked = true;
        }
        field(8; label; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'label', Locked = true;
        }

        //   "outstanding_balance"

        field(9; updated_at; DateTime)
        {
            Caption = 'Updated at';
            ToolTip = 'updated_at', Locked = true;
        }

        field(10; "interbank_code"; Code[10])
        {
            Caption = 'Interbank Code';
            ToolTip = 'interbank_code', Locked = true;
        }
        //   "journal": {
        //     "id": 106659446784,
        //     "url": "https://app.Pennylane.com/api/external/v2/journals/106659446784"
        //   },
        field(11; "bank_account.id"; BigInteger)
        {
            Caption = 'Bank Account Id', Locked = true;
            ToolTip = 'bank_account_id', Locked = true;
        }
        //   "bank_account": {
        //     "id": 16737099776,
        //     "url": "https://app.Pennylane.com/api/external/v2/bank_accounts/16737099776"
        //   },
        //   "pro_account_expense": null,
        //   "customer": null,
        //   "supplier": null,
        //   "categories": [],
        //   "matched_invoices": {
        //     "url": "https://app.Pennylane.com/api/external/v2/transactions/30519389503488/matched_invoices"



        // field(3; bank_description; Text[100])
        // {
        //     Caption = 'bank_description', Locked = true;
        //     ToolTip = 'bank_description', Locked = true;
        // }
        // field(6; booking_date; Date)
        // {
        //     Caption = 'booking_date', Locked = true;
        //     ToolTip = 'booking_date', Locked = true;
        // }
        // field(7; transaction_date; Date)
        // {
        //     Caption = 'transaction_date', Locked = true;
        //     ToolTip = 'transaction_date', Locked = true;
        // }
        // field(8; value_date; Date)
        // {
        //     Caption = 'value_date', Locked = true;
        //     ToolTip = 'value_date', Locked = true;
        // }
        // field(11; is_deleted; Boolean)
        // {
        //     Caption = 'is_deleted', Locked = true;
        //     ToolTip = 'is_deleted', Locked = true;
        // }
        // field(12; category_id; Integer)
        // {
        //     Caption = 'category_id', Locked = true;
        //     ToolTip = 'category_id', Locked = true;
        // }
        // field(13; account_id; BigInteger)
        // {
        //     Caption = 'account_id', Locked = true;
        //     ToolTip = 'account_id', Locked = true;
        //     TableRelation = "Wannylane Bank Account";
        // }
        // field(14; is_future; Boolean)
        // {
        //     Caption = 'is_future', Locked = true;
        //     ToolTip = 'is_future', Locked = true;
        // }
        // field(15; show_client_side; Boolean)
        // {
        //     Caption = 'show_client_side', Locked = true;
        //     ToolTip = 'show_client_side', Locked = true;
        // }
    }
    keys
    {
        key(PK; id)
        {
            Clustered = true;
        }
        // key(account_id; account_id)
        // {
        // }
    }

    procedure Load(bank_account_id: BigInteger; pFromDate: date)
    var
        WannylaneHelper: Codeunit "Wannylane Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec); // Is Temporary
        WannylaneHelper.Load(
            RecordRef,
            StrSubstNo(
                '/transactions?filter=[' +
                    '{"field": "bank_account_id", "operator": "eq", "value": "%1"},' +
                    '{"field": "date", "operator": "gt", "value": "%2"}]',
                bank_account_id,
                format(pFromDate, 0, 9)
            )
        );
    end;

    procedure Load()
    var
        WannylaneHelper: Codeunit "Wannylane Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec); // Is Temporary
        WannylaneHelper.Load(RecordRef, '/transactions');
    end;
}
