// On page load
$(function() {
  // Form validation
  // SEE: https://github.com/twitter/bootstrap/issues/202
  // SEE: Edit starting on line 648 of assets/javascripts/jquery.validate.js to make help-block show up.
  $('.event-form').validate({
      errorClass:'error',
      validClass:'success',
      errorElement:'p',
      highlight: function (element, errorClass, validClass) { 
        $(element).parents("div[class='control-group']").addClass(errorClass).removeClass(validClass); 
      }, 
      unhighlight: function (element, errorClass, validClass) { 
        $(element).parents(".error").removeClass(errorClass).addClass(validClass); 
      },
      invalidHandler: function(form, validator) {
        $('input[type="submit"]').removeAttr('disabled');
        $('input[type="reset"]').removeAttr('disabled');
      }
  });

  // Misc setup
  $('#event_group').chosen().change(function() {
    fadeInEventDetails();
  });
  $('.datepicker').datepicker({format: 'yyyy-mm-dd'});

  // Create page aesthetics
  if (RouteInfo.create_logic) {
    $('#event_details_panel').hide();
  }

  // Edit page aesthetics
  if (!RouteInfo.create_logic) {
    runMapPreview();
  }

  // Google Maps preview event hooks
  $('#event_original_address').blur(function() {
    runMapPreview();
  })

  // Address TBD checkbox
  $('#event_address_tbd').click(function() {
    if($('#event_address_tbd').is(':checked')) {
      $('.event_original_address_container').fadeOut();
      $('.map_container').fadeOut();
      $('#event_original_address').val('');
    } else {
      $('.event_original_address_container').fadeIn();
    }
  });

  // Automatically adujst end date and time after changing start date and time
  $('#event_start_time_date').on("blur", function(e) {
    $('#event_end_time_date').val($('#event_start_time_date').val());
  });

  $('#event_start_time_time').on("keyup", function(e) {
    $('#event_end_time_time').val(Date.parse($('#event_start_time_time').val()).add(1).hours().toString('HH:mm'));
  });

  // Group creation logic
  $('#create_new_group').click(function() {
    $('#select_group_panel').slideUp();
    $('#create_group_panel').fadeIn();
    $('#group_name').attr("required", "required");
    $('#event_group').val('').trigger("liszt:updated");
  });

  // Event group selection logic
  // We have to make this variable global
  var lastGroupEvent = null;

  if (RouteInfo.create_logic) {
    $('#event_group').change(function() {
      // Setup some variables
      // Determine the URL for the Ajax request
      var groupLastEventUrl = "/groups/" + $('#event_group').val() + "/last_event.json";

      // Add all of the elements to update to a JS array 
      var elementsToUpdate = new Array();
        elementsToUpdate['name']              = $('#event_name');
        elementsToUpdate['description']       = $('#event_description');
        elementsToUpdate['image']             = $('#event_image')
        elementsToUpdate['link']              = $('#event_link');
        elementsToUpdate['start_date']        = $('#event_start_date');
        elementsToUpdate['start_time']        = $('#event_start_time');
        elementsToUpdate['end_date']          = $('#event_end_date');
        elementsToUpdate['end_time']          = $('#event_end_time');
        elementsToUpdate['address']           = $('#event_original_address');
        elementsToUpdate['notes']             = $('#event_notes');

      // Populate form with appropriate data
      $.get(groupLastEventUrl, function(data) {                
        // If the form has a group selected, carefully overwrite values in form, otherwise proceed carelessly
        if (lastGroupEvent) {
          // Update only ones which haven't been changed from their original state since there's content in the form
          for (key in elementsToUpdate) {
            // We'll be using this element a lot, so we set it to a variable
            element = elementsToUpdate[key];

            // Update if the feild is not default/blank
            if (element.val() == lastGroupEvent[key] || element.val() == null) {
              element.val(data[key]);
            }
          };
        } else {
          // Update all of the fields since there's nothing in the form
          for (key in elementsToUpdate) {
            elementsToUpdate[key].val(data[key]);
          };
        }

        // Update image preview
        $('#event_image_preview').attr('src', data['image']);

        // Run Google Maps preview if address was filled in
        if (elementsToUpdate['address'].val() != "") {
          runMapPreview();
        }

        // Fade in the event details
        fadeInEventDetails();

        // Save last group's last event
        lastGroupEvent = data;
      });
    });  
  }

  // Pretty effects
  $('#group_name').keyup(function() {
    fadeInEventDetails();
  });
});

// Fades in #event_details_panel, if it's already visible, flash it
function fadeInEventDetails() {
  $details = $('#event_details_panel');
  if ( $details.is(':hidden') ) { return $details.fadeIn(1000); }
}

// Runs everything nessecary for map preview to show up
function runMapPreview() {
  initializeGoogleMaps();
  codeGoogleMapAddress($('#event_original_address').val());
  $('.map_container').fadeIn();
}

// Image upload preview logic
function handleFileSelect(evt) {
  var files = evt.target.files; // FileList object

  // Loop through the FileList and render image files as thumbnails
  for (var i = 0, f; f = files[i]; i++) {

    // Only process image files
    if (!f.type.match('image.*')) {
      continue;
    }

    var reader = new FileReader();

    // Closure to capture the file information.
    reader.onload = (function(theFile) {
      return function(e) {
        // Render image
        document.getElementById('event_image_preview').src = e.target.result
      };
    })(f);

    // Read in the image file as a data URL
    reader.readAsDataURL(f);
  }
}
document.getElementById('event_image').addEventListener('change', handleFileSelect, false);

// Google Maps preview setup code
var geocoder;
var map;
function initializeGoogleMaps() {
  geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(28.540563, -81.378703);
  var mapOptions = {
    zoom: 14,
    disableDefaultUI: true,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
}

function codeGoogleMapAddress() {
  var address = document.getElementById("event_original_address").value;
  geocoder.geocode({'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
      var marker = new google.maps.Marker({
          map: map,
          position: results[0].geometry.location
      });
    } else {
      console.log("Geocode was not successful for the following reason: " + status);
    }
  });
}