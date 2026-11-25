local events = captureEntities().events

if events:size() > 0 then
    local event = events[0]
    event:trigger()
    print(event.triggered)
    event:stop()
    print(event.triggered)
end