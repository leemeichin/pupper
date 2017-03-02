class FakeBackend < Pupper::Backend
  self.base_url = 'https://example.com/'
  self.headers = {
    'Authorization' => 'Bearer abcdefghijklmnopqrs'
  }
end
