defmodule ReplayNginxLogs.Request do
  use Tesla
  adapter Tesla.Adapter.Hackney

  # plug Tesla.Middleware.BaseUrl, "http://localhost:3000"
  plug Tesla.Middleware.BaseUrl, "https://app.underline.io"
  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/vnd.api+json"},
    {"Accept", "application/vnd.api+json"},
    # {"Cookie", "_underline_development_session=mIfidI8R0Y7rOnChDVbW2uDMFTB0qcS4AEqReXjAXIjq%2F6JUKsSAyNK5ZI7wWBrjFA%2Bbj1zZIVWK5QSv2DmHKyP9vWs3Mib78YHjx%2FVkjp19V5LOLEwEkmU%2Bx3pQpyoGaEbozA78EAC%2B7SOcsZbrmbjw%2FCdqCQs5np7rKwFU69Gk%2F1fDUOXjZMP5e5ReKzPyZXhcRMTSWB9fznyYErInuImXAzKPLcZaF9RxXpVqlcsBbQZMVhtfN%2FjEY5OVL4gT2PObkfTBkMnbDXV9HD2dgd74teDixtmZhXDoOHmuKdfGy7iSMPfRetJ50hA4Nz47O%2BW2AW229giRu7VGfcgeHBTLCdyRGCxHKam17ww0Gvp3FdhF%2FsSt65miDTWKp4yX4Nx%2FLsm5YtVCL7EqwkoCp0YxriXZa0axX6blApvQnLV9%2FGF%2BKdboGwR8R1JCgAllo1ql43tMbaB4IVnIeq8j5OLTYpU1MOF8VAYhr6SvFYjHAS9ghcyg0APWfO5V0%2FUr2bSxZ6CrmVqetKmuw5ZssrcaJ3Q0TEHIdRUiKLifSRwBCg%3D%3D--NO5oTeZWJa5ojw4s--1LS7nyJc8FaNIlbMs3dmPg%3D%3D"}
    {"Cookie", "_underline_session=BiLYQCFQ9U%2F9GIgQosL5vIlUe3Y0hIRazT0X9%2B5%2FyEPLhlHpcz6ZQJDTvpzFGD7sx7sZOpG9uQp3ZQQBsbUXWN9cpRWzhuI6CBSaVxJegxvcArpwHUNy9asmYZ9SX9AR3qQj%2B%2FyH%2BcOKvqVM%2BD3cqdY8zXyNiaoTESIioxGEzU5DYvkZCJQr72eq--ONE4qGtwBQMo1V6w--QhM84hFsLG92ppqPNlSbOw%3D%3D; domain=.underline.io; path=/; secure; HttpOnly; SameSite=None"}
  ]
  # plug Tesla.Middleware.Logger, log_level: :debug
  # plug Tesla.Middleware.JSON

  def match(line) do
    case line["method"] do
      "GET" -> get(line["path"])
      "PATCH" -> update(line["path"]) 
      _ -> {:skip}
    end
  end

  def update(path) do
    cond do
      String.starts_with?(path, "/api/v1/lectures") -> update_lecture(path)
      true -> {:skip}
    end
  end

  def update_lecture(path) do
    state = GenServer.call(ReplayNginxLogs.Data, :state)
    active_stream = !(state[:lectures][path] || false)
    GenServer.cast(ReplayNginxLogs.Data, {:lectures, path, active_stream})
    patch(path, "{\"data\": {\"attributes\": {\"lectures\": {\"active_stream\": #{active_stream}}}}}")
  end
end
