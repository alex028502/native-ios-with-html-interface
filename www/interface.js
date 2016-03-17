angular.module("DemoApp", ['ngResource']);

angular.module("DemoApp").controller('DemoController', function ($resource, $scope, $window) {
  var Note = $resource('http://localhost:8080/api/notes/:id');

  var refresh = function () {
    $scope.notes = Note.query();
  };

  $scope.addNote = function () {
    if (!$scope.new_note) return;
    var note = new Note({note:$scope.new_note});
    note.$save();
    $scope.new_note = "";
    refresh();
  };

  $scope.seeAll = function () {
    $window.location = "history-modal.html"
  };

  //not injecting dependency here
  //will test with real event
  //so not using $window.document
  //even though that would work
  document.addEventListener('viewDidAppear', refresh);

  refresh();
});

//thanks http://stackoverflow.com/a/15267754/5203563
angular.module("DemoApp").filter('reverse', function() {
  return function(items) {
    return items.slice().reverse();
  };
});