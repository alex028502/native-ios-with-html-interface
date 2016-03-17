describe('Protractor Demo App', function() {
  //not really using jasmine as intended here
  //this is just a list of steps for a simple run through

  it('load page', function () {
    browser.get('http://localhost:8080/clear-database-and-show-index');
  });

  it("should have a title even though it's not visible on the device", function() {
    expect(browser.getTitle()).toEqual('Embedded Angular');
  });

  it('should not have any items', function () {
    expect(element.all(by.repeater('note in notes')).count()).toBe(0);
  });

  it('should not have any text in form', function () {
    expect(element(by.model('new_note')).getText()).toBe("");
  });

  it('should not have any text in preview', function () {
    expect(element(by.id('preview')).getText()).toBe("");
  });

  it('should not have see all button', function () {
    expect(element(by.binding('see all')).isPresent()).toBeFalsy();
  });

  it('write something in the box', function () {
    element(by.model('new_note')).sendKeys("entry 1");
  });

  it('should be written in preview', function () {
    expect(element(by.id('preview')).getText()).toBe("entry 1");
  });

  it('but list is still empty', function () {
    expect(element.all(by.repeater('note in notes')).count()).toBe(0);
  });

  it('now submit', function () {
    element(by.id('save-button')).click();
  });

  it('now we have an item in the list', function () {
    expect(element.all(by.repeater('note in notes')).count()).toBe(1);
  });

  it("and it's the one we entered", function () {
    expect(element.all(by.repeater('note in notes')).get(0).getText()).toBe("entry 1");
  });

  it('not in preview', function () {
    expect(element(by.id('preview')).getText()).toBe("");
  });

  it('and form is clear again', function () {
    expect(element(by.model('new_note')).getText()).toBe("");
  });

  it('add another entry', function () {
    element(by.model('new_note')).sendKeys("entry 2");
    element(by.id('save-button')).click();
  });

  it('now we have an item in the list', function () {
    expect(element.all(by.repeater('note in notes')).count()).toBe(2);
  });

  it("newer at the top", function () {
    expect(element.all(by.repeater('note in notes')).get(0).getText()).toBe("entry 2");
  });

  it("older at the bottom", function () {
    expect(element.all(by.repeater('note in notes')).get(1).getText()).toBe("entry 1");
  });
});
