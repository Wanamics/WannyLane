namespace Wanamics.Wannylane.SupplierInvoices;

page 87434 "Wannylane Supplier Invoices"
{
    ApplicationArea = All;
    Caption = 'Wannylane Supplier Invoices';
    PageType = List;
    SourceTable = "Wannylane Supplier Inv. Proxy";
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.id)
                {
                }
                field(amount; Rec.amount)
                {
                }
                field(archived_at; Rec.archived_at)
                {
                }
                field(created_at; Rec.created_at)
                {
                }
                field(currency_amount_before_tax; Rec.currency_amount_before_tax)
                {
                }
                field(currency_amount; Rec.currency_amount)
                {
                }
                field(currency_tax; Rec.currency_tax)
                {
                }
                field(currency; Rec.currency)
                {
                }
                field("date"; Rec."date")
                {
                }
                field(deadline; Rec.deadline)
                {
                }
                field(filename; Rec.filename)
                {
                }
                field(invoice_number; Rec.invoice_number)
                {
                }
                field("label"; Rec."label")
                {
                }
                field(payment_status; Rec.payment_status)
                {
                }
                field(paid; Rec.paid)
                {
                }
                field(remaining_amount_with_tax; Rec.remaining_amount_with_tax)
                {
                }
                field(remaining_amount_without_tax; Rec.remaining_amount_without_tax)
                {
                }
                field(tax; Rec.tax)
                {
                }
                field(updated_at; Rec.updated_at)
                {
                }
                field(reconciled; Rec.reconciled)
                {
                }
                field(public_file_url; Rec.public_file_url)
                {
                }
                field(exchange_rate; Rec.exchange_rate)
                {
                }
                field(accounting_status; Rec.accounting_status)
                {
                }
                field("ledger_entry.id"; Rec."ledger_entry.id")
                {
                }
                field(transaction_reference; Rec.transaction_reference)
                {
                }
                field("supplier.id"; Rec."supplier.id")
                {
                }
                field(payment_method_ledger_account; Rec.payment_method_ledger_account)
                {
                }
                field(external_reference; Rec.external_reference)
                {
                }
                field(import_source; Rec.import_source)
                {
                }
                field(e_invoicing; Rec.e_invoicing)
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Load();
    end;
}
