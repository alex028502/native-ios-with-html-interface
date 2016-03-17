describe('api', function () {
  //we never reset initial conditions in these tests since it is outside the
  //browser's control.  We just take advantage of jasmine's asynchronous test
  //setup to do three tests that depend on passing on the state
  var expectedInitialData = [{note:"test note 1"}, {note:"test note 2"}];
  var additonalItem = {note: "test note 3"};

  describe('but first a general question - concat', function () {
    it('should not modify array in place', function () {
      var original = ["A", "B"];
      var combined = original.concat(["C"]);
      expect(combined).toEqual(["A", "B", "C"]);
      expect(original).toEqual(["A", "B"]);
    });
  });

  describe('after running the initial setup', function () {
    it('should give you initial data with get', function (done) {
      $.get("http://localhost:8080/api/notes", function(data, status) {
        expect(status).toBe("success");
        expect(data).toEqual(expectedInitialData);
        done();
      });
    });

    it('should allow you post', function (done) {
      $.ajax({
        url: "http://localhost:8080/api/notes",
        type: "post",
        data: JSON.stringify(additonalItem),
        contentType: 'application/json; charset=utf-8',
        dataType: "json",
        success: function (data) {
          //as long as success is in there somewhere we are happy for now
          expect(JSON.stringify(data)).toContain("success")
          done();
        },
        error: function (a, b, c) {
          //this just prints out all the arguments to the fail so that we can
          //see what went wrong
          expect("fail").toBe(a);
          expect("fail").toBe(b);
          expect("fail").toBe(c);
          done();
        }
      });
    });

    var expectedFinalData;
    it('should have added posted item', function (done) {
      $.get("http://localhost:8080/api/notes", function(data, status) {
        expect(status).toBe("success");
        expectedFinalData = expectedInitialData.concat([additonalItem]);
        expect(expectedFinalData.length).toBe(3);//sanity check
        expect(data).toEqual(expectedFinalData);
        done();
      });
    });

    it('should recognise a delete, but tell you not implemented', function (done) {
      //really just to prove that we can implement a full rest api with all methods
      $.ajax({
        url: "http://localhost:8080/api/notes/0",
        type: "delete",
        contentType: 'application/json; charset=utf-8',
        dataType: "json",
        success: function (data) {
          expect(data).toBe("not expecting success - fail")
          done();
        },
        error: function (a, b, c) {
          expect(a.responseText).toContain("delete not implemented");
          expect(b).toBe("error");
          expect(c).toBe("Not Implemented");//I think jquery translates 501 for us
          done();
        }
      });
    });

    it('should not change anything', function (done) {
      $.get("http://localhost:8080/api/notes", function(data, status) {
        expect(status).toBe("success");
        expect(expectedFinalData.length).toBe(3);//sanity check
        expect(data).toEqual(expectedFinalData);
        done();
      });
    });

    it('should recognise a put, but tell you not implemented', function (done) {
      //really just to prove that we can implement a pull rest api with all methods

      $.ajax({
        url: "http://localhost:8080/api/notes/0",
        type: "put",
        data: JSON.stringify({note:"this will not work because not implemented",id:0}),
        contentType: 'application/json; charset=utf-8',
        dataType: "json",
        success: function (data) {
          expect(data).toBe("not expecting success - fail")
          done();
        },
        error: function (a, b, c) {
          expect(a.responseText).toContain("update not implemented");
          expect(b).toBe("error");
          expect(c).toBe("Not Implemented");//I think jquery translates 501 for us
          done();
        }
      });
    });

    it('should not change anything again', function (done) {
      $.get("http://localhost:8080/api/notes", function(data, status) {
        expect(status).toBe("success");
        expect(expectedFinalData.length).toBe(3);//sanity check
        expect(data).toEqual(expectedFinalData);
        done();
      });
    });

  });
});
