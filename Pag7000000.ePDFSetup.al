page 7000000 "ePDF Setup"
{
    PageType = Card;
    SourceTable = "ePDF Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Sender Email ID"; "Sender Email ID")
                {
                    ApplicationArea = All;
                }
                field("Sender Name"; "Sender Name")
                {
                    ApplicationArea = All;
                }
                field("CC Email to Sender"; "CC Email to Sender")
                {
                    ApplicationArea = All;
                }
            }
            group("Document Code Setup")
            {
                field("Vendor Statement"; "Vendor Statement")
                {
                    ApplicationArea = All;
                }
                field("Purchase Order"; "Purchase Order")
                {
                    ApplicationArea = All;
                }
                field("Purchase Invoice"; "Purchase Invoice")
                {
                    ApplicationArea = All;
                }
                field("Purchase Quote"; "Purchase Quote")
                {
                    ApplicationArea = All;
                }
                field("Purchase Return Order"; "Purchase Return Order")
                {
                    ApplicationArea = All;
                }
                field("Posted Purchase Receipt"; "Posted Purchase Receipt")
                {
                    ApplicationArea = All;
                }
                field("Posted Purchase Invoice"; "Posted Purchase Invoice")
                {
                    ApplicationArea = All;
                }
                field("Posted Purch Return Shipment"; "Posted Purch Return Shipment")
                {
                    ApplicationArea = All;
                }
                field("Posted Purch Credit Memo"; "Posted Purch Credit Memo")
                {
                    ApplicationArea = All;
                }
                field("Sales Order"; "Sales Order")
                {
                    ApplicationArea = All;
                }
                field("Customer Statement"; "Customer Statement")
                {
                    ApplicationArea = All;
                }
                field("Sales Invoice"; "Sales Invoice")
                {
                    ApplicationArea = All;
                }
                field("Sales Quote"; "Sales Quote")
                {
                    ApplicationArea = All;
                }
                field("Sales Return Order"; "Sales Return Order")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Shipment"; "Posted Sales Shipment")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoice"; "Posted Sales Invoice")
                {
                    ApplicationArea = All;
                }
                field("Posted Service Sales Invoice"; "Posted Service Sales Invoice")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Return Receipt"; "Posted Sales Return Receipt")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Credit Memo"; "Posted Sales Credit Memo")
                {
                    ApplicationArea = All;
                }
                field("Remittance Advice"; "Remittance Advice")
                {
                    ApplicationArea = All;
                }
                field("Issued Finance Charge"; "Issued Finance Charge")
                {
                    ApplicationArea = All;
                }
                field("Issued Reminder"; "Issued Reminder")
                {
                    ApplicationArea = All;
                }
                field("Transfer Order"; "Transfer Order")
                {
                    ApplicationArea = All;
                }
            }
            group("Customer Statement Setup")
            {
                field("All With Entries"; "Stmt Print All With Entries")
                {
                    ApplicationArea = All;
                }
                field("All With Balance"; "Stmt Print All With Balance")
                {
                    ApplicationArea = All;
                }
                field("Update Statement No"; "Stmt Update Statement No")
                {
                    ApplicationArea = All;
                }
                field("Print Company Address"; "Stmt Print Company Address")
                {
                    ApplicationArea = All;
                }
                field("Print in LCY"; "Stmt Print in LCY")
                {
                    ApplicationArea = All;
                }
                field("Statement Style"; "Stmt Statement Style")
                {
                    ApplicationArea = All;
                }
                field("Aged By"; "Stmt Aged By")
                {
                    ApplicationArea = All;
                }
                field("Length of Aging Period"; "Stmt Length of Aging Period")
                {
                    ApplicationArea = All;
                }
                field("Date Filter"; "Stmt Date Filter")
                {
                    ApplicationArea = All;
                }
            }
            group("Vendor Statement Setup")
            {
                field("V Stmt Print All With Entries"; "V Stmt Print All With Entries")
                {
                    //Caption = "All With Entries";
                    ApplicationArea = All;
                }
                field("V Stmt Print All With Balance"; "V Stmt Print All With Balance")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Update Statement No"; "V Stmt Update Statement No")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Print Company Address"; "V Stmt Print Company Address")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Print in LCY"; "V Stmt Print in LCY")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Statement Style"; "V Stmt Statement Style")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Aged By"; "V Stmt Aged By")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Length of Aging Period"; "V Stmt Length of Aging Period")
                {
                    ApplicationArea = All;
                }
                field("V Stmt Date Filter"; "V Stmt Date Filter")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group("&Setup")
            {
                action("&Document List")
                {
                    ApplicationArea = All;
                    // "RunObject" sets the "Reward List" page as the object 
                    // that will run when the action is activated.
                    Image = Documents;                   
                    RunObject = Page "ePDF Document List";
                    trigger OnAction();
                    begin
                    end;
                }
            }
        }
    }
}
