$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hit();
});

function player_hits() {
$(document).on("click", "form#hit_form input", function() {
    alert("Player Hits!");
    $.ajax({
      type: 'POST',
      url: "/game/player/hit"
    }).done(function(msg) {
      $("div#game").replaceWith(msg)
    });
    return false;
  });
}

function player_stays() {
$(document).on("click", "form#stay_form input", function() {
    alert("Player Stays!");
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(msg) {
      $("div#game").replaceWith(msg)
    });
    return false;
  });
}