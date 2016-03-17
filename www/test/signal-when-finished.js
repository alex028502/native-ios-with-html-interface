//thanks http://stackoverflow.com/a/16149679/5203563
var checkExist = setInterval(function() {
  if (document.getElementsByClassName('jasmine-results')) {
    var resultDiv = document.getElementsByClassName('jasmine-results')[0];
    resultDiv.innerHTML = resultDiv.innerHTML + "<div>done!</div>"
    clearInterval(checkExist);
  }
}, 100);

//I can only figure out how to make ui tests check for elements using the full
//inner html.  However, the jasmine test runner doesn't put any text anywhere
//that we can grab on to.  It's all stuff that changes based on results.  So
//this puts a div at the bottom when the tests are finished.
