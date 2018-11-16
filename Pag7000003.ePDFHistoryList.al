page 7000003 "ePDF History List"
{
    PageType = List;
    SourceTable = "ePDF History";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {

                }
                field("Document No."; "Document No.")
                {

                }
                field("Entity Type"; "Entity Type")
                {

                }
                field("Entity No.";"Entity No.")
                {

                }
                field(Description;Description)
                {

                }
                field("Date Logged"; "Date Logged")
                {

                }
                field("Time Logged"; "Time Logged")
                {

                }
                field("Logged By"; "Logged By")
                {

                }
                field("PDF Path"; "PDF Path")
                {

                }
                field("Date Processed"; "Date Processed")
                {

                }
                field("Time Processed"; "Time Processed")
                {

                }
                field("Processed By"; "Processed By")
                {

                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                action("Show Document")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction();
                    var
                        ePDFMgmt : Codeunit "ePDF Management";
                    begin
                        ePDFMgmt.ShowDocument("Document Code","Document No.");
                    end;
                }
                action("Show Recipient")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction();
                    var
                        ePDFMgmt : Codeunit "ePDF Management";
                    begin
                        ePDFMgmt.ShowRecipient("Document Code","Document No.");
                    end;
                }
                action("Show Email Addresses")
                {
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Report;
                    RunObject = Page "ePDF Email Addresses";
                    RunPageLink = "Document Code"=FIELD("Document Code"),"Entity Type"=FIELD("Entity Type"),"Entity No."= FIELD("Entity No.");
                    trigger OnAction();
                    var
                    begin
                    end;
                }
            
            }
        }
    }
}