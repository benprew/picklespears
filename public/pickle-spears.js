$(function() {
  $( ".dialog" ).dialog({
      autoOpen: false,
      modal: true,
  });

  $( ".opener" ).click(function(e) {
    e.preventDefault();
    $("#dialog-" + e.srcElement.id).dialog("open");
    return false;
  });

  $("a[href*='/game/attending_status']").click(function(e) {
    e.preventDefault();
    function updateDiv(data) {
      $("#status_" + e.srcElement.id).html(data);
    }
    $.get(e.srcElement.href, { game_id: e.srcElement.id }, updateDiv)
  });

  $( ".join_team" ).click(function(e) {
    e.preventDefault();
    var team_id = e.srcElement.id
    $.get('/team/join', { team_id: team_id }, function(data) { $("#" + team_id).html(data) });
  });
});

$(document).ready(function() {
  $("#add_game_form").submit( function() {
    date = Date.parse($("#game_date_string").val())
    $("#massaged_date").text(date.toString("MM/DD/YYYY h:mm tt"))
  });
});

