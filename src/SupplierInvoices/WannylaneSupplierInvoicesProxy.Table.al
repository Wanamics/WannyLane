namespace Wanamics.Wannylane.SupplierInvoices;

using Wanamics.Wannylane.Request;
table 87433 "Wannylane Supplier Inv. Proxy"
{
    Caption = 'Wannylane Supplier Inv. Proxy';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; id; BigInteger) { }
        field(2; amount; Decimal) { }
        field(3; archived_at; DateTime) { }
        field(4; "created_at"; DateTime) { }
        field(5; "currency_amount_before_tax"; Decimal) { }
        field(6; "currency_amount"; Decimal) { }
        field(7; "currency_tax"; Decimal) { }
        field(8; "currency"; Code[10]) { }
        field(9; "date"; Date) { }
        field(10; "deadline"; Date) { }
        field(11; "filename"; Text[100]) { }
        //   field(12 ; "id"; BigInteger) {}
        field(13; "invoice_number"; Text[35]) { }
        field(14; "label"; Text[100]) { }
        field(15; "payment_status"; Text[20]) { } // Enum ?
        field(16; "paid"; Boolean) { }
        field(17; "remaining_amount_with_tax"; Decimal) { }
        field(18; "remaining_amount_without_tax"; Decimal) { }
        field(19; "tax"; Decimal) { }
        field(20; "updated_at"; DateTime) { }
        field(21; "reconciled"; Boolean) { }
        field(22; "public_file_url"; Text[250]) { } //: "https://app.pennylane.com/public/invoice/pdf?encrypted_id=txQMkAzSEW4Cr%2FyJLy7VusV9U9YJDEWJUMHljHk5je9ZBeOwgtaCMz2WKGd%2FDUvfh%2F2A3Dwiy3%2B5Z23gLzU7o7SbVEa6E1fJ5TtPSa3wnsntPinuq3tLISbBrVlfiA%3D%3D--4SdreblzTjIh0NhM--b1OCDwMBLZ55pxeFrQzu5Q%3D%3D",
        field(23; "exchange_rate"; Decimal) { }
        field(24; "accounting_status"; Text[20]) { } // Enum ?  
        field(25; "ledger_entry.id"; BigInteger) { }
        field(26; "transaction_reference"; Text[50]) { }
        field(27; "supplier.id"; BigInteger) { }
        field(28; "payment_method_ledger_account"; Text[20]) { }
        field(29; "external_reference"; Text[35]) { }
        field(30; "import_source"; Text[50]) { }
        field(31; "e_invoicing"; Text[50]) { }
    }
    keys
    {
        key(PK; id)
        {
            Clustered = true;
        }
    }
    procedure Load()
    var
        WannylaneHelper: Codeunit "Wannylane Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        WannylaneHelper.Load(RecordRef, '/supplier_invoices');
    end;
}
