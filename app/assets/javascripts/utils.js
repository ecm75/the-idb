IDB.Utils = {
  renderMarkupPreview: function(text, target) {
    var path = '/markup/render';

    if (!$.isFunction(target)) {
      $(target).html('<p>Loading...</p>');
    }

    $.post(path, text).done(function (data) {
      if ($.isFunction(target)) {
        target(data);
      } else {
        if (data.length) {
          $(target).html(data);
        } else {
          $(target).html('<p>Empty...</p>');
        }
      }
    });
  },

  renderTimeago: function (selector) {
    $(selector).timeago();
  },

  ajaxLoaderFor: function (element, text) {
    if (text) { $(element).html(text); }
    $(element).addClass('ajax-loader');

    return {
      stop: function (removeText) {
        if (removeText) { $(element).html(''); }
        $(element).removeClass('ajax-loader');
      }
    };
  }
};

$(function () {
  $('#location_location_level_id').change(function() {
    $.ajax( {
      url: "/locations/get_parent_locations",
      type: 'GET',
      data: {
        level: $("#location_location_level_id").val()
      },
      async: true,
      dataType: "json",
      error: function(XMLHttpRequest, errorTextStatus, error) {
                alert("Failed: " + errorTextStatus + " ;" + error);
            },
      success: function(data) {
        $("#location_location_id").empty();

        if (data.length <= 0) {
          $("#location_location_id").parent().parent().hide();
        } else {
          $("#location_location_id").parent().parent().show();
        }
        for(var i in data) {
          var id = data[i].id;
          var title = data[i].name;
          $("#location_location_id").append(new Option(title, id));
        }
      }
    });
  });

  // the selector starts as 'Country', so no parent possible, so hide the selector
  $("#location_location_id").parent().parent().hide();

  $(".raw_api_data_headline").click(function() {
    if($(this).next().is(':visible')) {
      $(this).next().slideUp();
    } else {
      $(this).next().slideDown();
    }
  });

  $(".puppet_db_data_headline").click(function() {
    if($("#puppet_db_data").is(':visible')) {
      $("#puppet_db_data").slideUp();
    } else {
      $("#puppet_db_data").slideDown();
    }
  });
});
