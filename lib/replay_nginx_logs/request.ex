defmodule ReplayNginxLogs.Request do
  use Tesla
  adapter Tesla.Adapter.Hackney

  # plug Tesla.Middleware.BaseUrl, "http://localhost:3000"
  plug Tesla.Middleware.BaseUrl, "https://app.underline.io"
  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/vnd.api+json"},
    {"Accept", "application/vnd.api+json"},
    {"Cookie", "_underline_session=jKEtur%2FcurjLaxqrg61pWU9hcZ3%2B%2FrA4Fm35BCjjepMkVr0JCXEpEEkx6cQ%2Fq%2F6E8MFYYY2lG%2Bmtup7C5xGfLyFgllpAlhiQf0CA1tXmWHSG6t90eoW2Gm%2BUkBPrEPej7iPuGs4T5Y26VzQhyj7bD%2BhZyz4yz%2BOL4Tos%2B5N8vZXYyIh6bAusYvrPhyAgFpQB%2Biu7t96vHU7%2BV4gK26d7BTFQz27KlSzh34l1HRmvSE%2FFAsD3uu4G3wcZPcQDhuSZAqz02LOPPHdrjHZmC7fcmwokzG6hT8vbwLeyJQHQ1CNeiwdWOwV1AEQs3GlvAwF%2Fy%2FeKORmtQlscqk%2BzaqKhGxHj7EwJ2Q%3D%3D--tlEo%2BI%2BcL9UtbvDI--TGFQIBsl%2FF%2FTxrYZQNBnIA%3D%3D"}
    # {"Cookie", "_underline_development_session=mIfidI8R0Y7rOnChDVbW2uDMFTB0qcS4AEqReXjAXIjq%2F6JUKsSAyNK5ZI7wWBrjFA%2Bbj1zZIVWK5QSv2DmHKyP9vWs3Mib78YHjx%2FVkjp19V5LOLEwEkmU%2Bx3pQpyoGaEbozA78EAC%2B7SOcsZbrmbjw%2FCdqCQs5np7rKwFU69Gk%2F1fDUOXjZMP5e5ReKzPyZXhcRMTSWB9fznyYErInuImXAzKPLcZaF9RxXpVqlcsBbQZMVhtfN%2FjEY5OVL4gT2PObkfTBkMnbDXV9HD2dgd74teDixtmZhXDoOHmuKdfGy7iSMPfRetJ50hA4Nz47O%2BW2AW229giRu7VGfcgeHBTLCdyRGCxHKam17ww0Gvp3FdhF%2FsSt65miDTWKp4yX4Nx%2FLsm5YtVCL7EqwkoCp0YxriXZa0axX6blApvQnLV9%2FGF%2BKdboGwR8R1JCgAllo1ql43tMbaB4IVnIeq8j5OLTYpU1MOF8VAYhr6SvFYjHAS9ghcyg0APWfO5V0%2FUr2bSxZ6CrmVqetKmuw5ZssrcaJ3Q0TEHIdRUiKLifSRwBCg%3D%3D--NO5oTeZWJa5ojw4s--1LS7nyJc8FaNIlbMs3dmPg%3D%3D"}
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
    patch(path, "{\"data\": {\"type\": \"lectures\", \"attributes\": {\"active_stream\": #{active_stream}}}}")
  end
end
