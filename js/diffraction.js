$( document ).ready( function() {
	$("#refresh").click( function() {
	    /* Send POST request to server, with textarea contents */
    	$.get( $("#index").val() + '/' + $("#year").val(), function( json ) {
    	    var quotes = eval( json );
    	    var spectrum = '';
    	    
    	    for( var i in quotes ) {
    	        spectrum += "<div class='bar' style='background-color: hsl(" + 
    	                    ( 256 - Math.round( quotes[ i ] ) ) + 
    	                    ",50%," + "50" + "%);'></div>";
    	    }
    		$("div#spectrum").fadeOut('slow', function() { 
    		    $( this ).html( spectrum ).fadeIn('medium'); 
    		});	
    	});
    	return false;
 	});
});