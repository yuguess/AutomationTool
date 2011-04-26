$(document).ready(function() {

$("#first_step").live("click", function(){
    $("#column2").load("fill_form.php");
    $("#first_item").html("Step 1");
    $("#second_item").html("<a id=\"selected\" href=\"#\">Step 2</a>");
});

$("#second_step").live("click", function(){
    $("#column2").load("check_insert.php");
    $("#second_item").html("Step 2");
    $("#third_item").html("<a id=\"selected\" href=\"#\">Step 3</a>");
});

$(function() {
    $('#file1').change(function() {
        $(this).upload('upload/demo_upload.php', function(res) {
            alert("ok");
            $(res).insertAfter(this);
        });
    });
});


});
