<!--#include virtual="/includes/variables.inc.asp" -->

<% 
PageTitle="Welcome" & " : " & Environment.Item("COMPUTERNAME") 

%>
    <!DOCTYPE html>
    <html>

    <head>
        <!--#include virtual="/includes/header.inc.asp" -->
    </head>

    <body>
        <!--#include virtual="/includes/nav.inc.asp" -->
        <section class="hero is-large">
            <div class="hero-body">
                <p class="title">
                Desired State Configuration Demo
                </p>
                <p class="subtitle">
                How to deploy a virtual maching with Bicep and configure it with DSC
                </p>
                <p>Coming at you from <%= Environment.Item("COMPUTERNAME")%></p>
            </div>
        </section>
    </body>
    <!--#include virtual="/includes/footer.inc.asp" -->

    </html>