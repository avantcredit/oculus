describe("Ajax Update Query Test", function() {

  beforeEach(function () {
    jasmine.Ajax.installMock();
    jasmine.Ajax.useMock();
    clearAjaxRequests();
  });

  it("should trigger ajax post to '/oculus/queries/:id/update'", function() {    
    var sql = "show tables";
    var id = "23";
    
    UpdateQuery(id, sql);
    var request = mostRecentAjaxRequest();
        
    expect(request.url).toBe("/oculus/queries/" + id + "/update");
    expect(request.method).toBe('POST');
    expect(request.params).toEqual("query=show+tables");

  });
});
