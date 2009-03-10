$( document ).ready( function() {
    $("#refresh").click( function() {
        /* Fetch quotes from server */
        $.get( $("#index").val() + '/' + $("#year").val(), function( json ) {
            var quotes = eval( json ); /* Convert json data into object */
            var spectrum = '';
            
            /* Create the spectrum */
            for( var i in quotes ) {
                spectrum += "<div class='bar' style='background-color: hsl(" + 
                            ( 256 - Math.round( quotes[ i ] ) ) + 
                            ",50%," + "50" + "%);'></div>";
            }
            /* Hide the old spectrum and show the new one */
            $("div#spectrum").fadeOut('slow', function() { 
                $( this ).html( spectrum ).fadeIn('medium'); 
            }); 
        });
        return false;
    });
});