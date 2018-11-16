page 7000001 "ePDF Document List"
{
    PageType = List;
    SourceTable = "ePDF Document Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Code"; "Document Code")
                {

                }
                field("Document Description"; "Document Description")
                {

                }
                field(Enable; Enable)
                {

                }
                field("Use Batch Processing"; "Use Batch Processing")
                {

                }
                field("Related Report ID"; "Related Report ID")
                {

                }
                field("Alternate Report ID"; "Alternate Report ID")
                {

                }
                field("Email Subject"; "Email Subject")
                {

                }
                field("Email Body 1"; "Email Body 1")
                {

                }
                field("Email Body 2"; "Email Body 2")
                {

                }
                field("Email Body 3"; "Email Body 3")
                {

                }
                field("Email Body 4"; "Email Body 4")
                {

                }
                field("Default Path to Store PDF"; "Default Path to Store PDF")
                {

                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Setup)
            {
                action("&Email Addresses")
                {
                    Image = Email;
                    RunObject = Page "ePDF Email Addresses";
                    //Need to look how to define the RunpageLink
                    RunPageLink = "Document Code"=FIELD("Document Code");
                }
            }
        }
    }
}