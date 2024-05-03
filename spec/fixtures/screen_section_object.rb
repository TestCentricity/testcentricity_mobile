class TestScreenSection < TestCentricity::ScreenSection
  trait(:section_locator) { { accessibility_id: 'test section' } }
  trait(:section_name)    { 'Basic Test Section' }

  elements   element1: { accessibility_id: 'element 1' }
  buttons    button1:  { accessibility_id: 'button 1' }
  textfields field1:   { accessibility_id: 'text input 1' }
  checkboxes check1:   { accessibility_id: 'checkbox 1' }
  radios     radio1:   { accessibility_id: 'radio 1' }
  labels     label1:   { accessibility_id: 'label 1' }
  images     image1:   { accessibility_id: 'image 1' }
  switches   switch1:  { accessibility_id: 'switch 1' }
  lists      list1:    { accessibility_id: 'list 1' }
  sections   section2: TestScreenSection
end
