$( document ).ready( function() {
    $("#refresh").click( function() {
        /* Fetch quotes from server */
        $.getJSON( $("#index").val() + '/' + $("#year").val(), function( quotes ) {
            var spectrum = '';
            var S = 70, L = 50;
            var now = new Date();
            var distance = now.getFullYear() - $("#year").val();
            var size = 2;
            
            if( distance == 0 )
                size = 3;
            else if( distance > 0 && distance < 3 )
                size = 2;
            else
                size = 1;
            
            $("div.bar").css("width", size + "px");
            
            /* Create the spectrum */
            for( var i in quotes ) {
                spectrum += "<div class='bar' style='background-color: hsl(" + 
                            quotes[ i ] +  
                            "," + S + "%," + L + "%);'></div>";
            }
            /* Hide the old spectrum and show the new one */
            $("div#spectrum").fadeOut('fast', function() { 
                $( this ).html( spectrum ).fadeIn('medium'); 
            }); 
        });
        return false;
    });
});