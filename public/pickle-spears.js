function joinTeam(team_id, elem_id) {
  jx.load('/team/join?team_id=' + team_id,
    function(response) {
      document.getElementById(elem_id).innerHTML = response;
    }
  )
}

function set_attending_status(game_id, attending_status, elem_id) {
  jx.load('/game/attending_status?game_id=' + game_id + ';status=' + attending_status,
    function(response) {
      document.getElementById(elem_id).innerHTML = response;
    }
  )
}

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
});
