// On page load
$(function() {
	// Disable submit button on submit
    $('#subscription-form').submit(function(){
        $('input[type=submit]', this).attr('disabled', 'disabled');
        $(".subscription-error").fadeOut("slow");
    });
});