$(function() {
  $("a[href*='/attending_status']").click(function(e) {
    e.preventDefault();
    button = $(this);
    function updateDiv(data) {
      button.parent().parent().html(data)
    }
    $.get(button.attr('href'), updateDiv);
  });

  $( ".join_team" ).click(function(e) {
    e.preventDefault();
    var team_id = e.target.id
    $.get('/team/join', { team_id: team_id }, function(data) { $("#" + team_id).html(data) });
  });
});

$(document).ready(function() {
  $("#add_game_form").submit( function() {
    date = Date.parse($("#game_date_string").val())
    $("#massaged_date").text(date.toString("MM/DD/YYYY h:mm tt"))
  });
});

$('.datepicker').datepicker();
