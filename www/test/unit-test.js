function getMockData() {
  //make sure we are always getting a new object like this:
  return JSON.parse('[{"note":"note 1"}, {"note":"note 2"}]');
}

describe("DemoController", function () {
  it("quickly check the mock data object", function () {
    expect(getMockData()).toEqual([{note:"note 1"}, {note:"note 2"}]);
    expect(getMockData()).not.toBe(getMockData());
    expect(getMockData()).toEqual(getMockData());
  });

  beforeEach(module('DemoApp'));

  var $controller, $resource, $scope, $window, MockNote;

  beforeEach(inject(function (_$controller_) {
    $controller = _$controller_;
    $scope = {};

    MockNote = function (noteDictionary) {
      this.$save = function () {
        MockNote.savedNotes.push(noteDictionary)
      }
    };
    MockNote.savedNotes = [];
    MockNote.query = function () {
      return MockNote.savedNotes;//using the same property for incoming and outgoing mock data
    };

    $resource = function (url) {
      if (url != 'http://localhost:8080/api/notes/:id') {
        throw "only expecting to call resource with this one url"
      }
      return MockNote;
    };
    $window = {}
  }));

  describe("when fired up with no initial data", function () {
    beforeEach(function () {
      MockNote.savedNotes = [];
      $controller('DemoController', {$resource: $resource, $scope:$scope, $window:$window});
    });

    it('should set addNote method', function () {
      expect(typeof $scope.addNote).toBe("function");
    });

    it('should set seeAll method', function () {
      expect(typeof $scope.seeAll).toBe("function");
    });

    it('should set notes', function () {
      expect($scope.notes).toEqual([]);
    });

    describe("when new note is submitted", function () {
      beforeEach(function () {
        $scope.new_note = "first note";
        $scope.addNote()
      });

      it('should clear the form', function () {
        expect($scope.new_note).toBe("");
      });

      it('should save the note and refresh', function () {
        //our mock $resource saves incoming mock data
        //to outgoing mock data so we can test this without adding mock data
        expect($scope.notes).toEqual([{note:"first note"}]);
      });
    });

  });

  describe("when fired up with initial data", function () {
    beforeEach(function () {
      MockNote.savedNotes = getMockData();
      $controller('DemoController', {$resource: $resource, $scope:$scope, $window:$window});
    });

    it('should set addNote method', function () {
      expect(typeof $scope.addNote).toBe("function");
    });

    it('should set seeAll method', function () {
      expect(typeof $scope.seeAll).toBe("function");
    });

    it('should set notes', function () {
      expect($scope.notes).toEqual(getMockData());
    });

    describe("when a change is made in another view", function () {
      beforeEach(function () {
        MockNote.savedNotes = []; //the same change that we are expecting
        //but if another view were able to add notes, it should work for that too
      });

      it('should not do anything', function () {
        expect($scope.notes).toEqual(getMockData());
      });

      describe("and a refresh signal comes from the native layer", function () {
        beforeEach(function () {
          document.dispatchEvent(new Event('viewDidAppear'));
        });

        it('this view should update', function () {
          expect($scope.notes).toEqual([]);
        });
      });
    });

    describe("when new note is submitted", function () {
      beforeEach(function () {
        $scope.new_note = "new note";
        $scope.addNote()
      });

      it('should clear the form', function () {
        expect($scope.new_note).toBe("");
      });

      it('should save the note and refresh', function () {
        expect($scope.notes).toEqual(getMockData().concat([{note:"new note"}]));
      });
    });

    describe("when a blank note is submitted", function () {
      beforeEach(function () {
        $scope.new_note = "";
        $scope.addNote()
      });

      it('should leave the form clear', function () {
        expect($scope.new_note).toBe("");
      });

      it('should leave the data as they were', function () {
        expect($scope.notes).toEqual(getMockData());
      });

    });

  });


});