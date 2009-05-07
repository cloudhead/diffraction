$( document ).ready( function() {
    $("#refresh").click( function() {
        /* Fetch quotes from server */
        $.getJSON( $("#index").val() + '/' + $("#year").val(), function( quotes ) {
            var spectrum = '';
            var S = 70, L = 50;
            /* Create the spectrum */
            for( var i in quotes ) {
                spectrum += "<div class='bar' style='background-color: hsl(" + 
                            quotes[ i ] +  
                            "," + S + "%," + L + "%);'></div>";
            }
            /* Hide the old spectrum and show the new one */
            $("div#spectrum").fadeOut('slow', function() { 
                $( this ).html( spectrum ).fadeIn('medium'); 
            }); 
        });
        return false;
    });
});