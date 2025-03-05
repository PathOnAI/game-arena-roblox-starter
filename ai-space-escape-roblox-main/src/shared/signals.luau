--!strict

local server_storage = game:GetService"ServerStorage";
local replicated_storage = game:GetService"ReplicatedStorage";
local starter_player_scripts = game:GetService"StarterPlayer".StarterPlayerScripts;
local run_service = game:GetService"RunService";

local ease = require(replicated_storage.Shared.ease);

local module = {
  be = {folder = ease.folder(if run_service:IsServer() then server_storage else starter_player_scripts, "be")},
  bf = {folder = ease.folder(if run_service:IsServer() then server_storage else starter_player_scripts, "bf")},
  re = {folder = if run_service:IsServer() then ease.folder(replicated_storage, "re") else replicated_storage:FindFirstChild"re"},
  rf = {folder = if run_service:IsServer() then ease.folder(replicated_storage, "rf") else replicated_storage:FindFirstChild"rf"}
};
local signals = {};
local methods = {};
methods.__index = methods;

local function create_signal(category, id):BindableEvent | BindableFunction | RemoteEvent | RemoteFunction
  local case = ({be = "BindableEvent", bf = "BindableFunction", re = "RemoteEvent", rf = "RemoteFunction"})[category.id];
  local signal:BindableEvent | BindableFunction | RemoteEvent | RemoteFunction = Instance.new(case);
  signal.Name = id;
  signal.Parent = category.folder;
return signal end

function methods:connect(id:string, procedure)
  if signals[self.id][id] then error("signal "..id.." already exists") end

  signals[self.id][id] = ({
    be = function(signal:BindableEvent) signal.Event:Connect(procedure) return signal end,
    bf = function(signal:BindableFunction) signal.OnInvoke = procedure return signal end,
    re = function(signal : RemoteEvent) signal.OnServerEvent:Connect(procedure) return signal end,
    rf = function(signal:RemoteFunction) signal.OnServerInvoke = procedure return signal end,
  })[self.id](create_signal(self, id));
end

function methods:disconnect(id:string)
  signals[self.id][id]:Destroy();
  signals[self.id][id] = nil;
end

table.freeze(methods);

-- BindableEvent signal methods
function module.be:fire(id:string, ...)
  signals[self.id][id]:Fire(...);
end

setmetatable(module.be, methods);

-- BindableFunction signal methods
function module.bf:fire(id:string, ...)
  local result = signals[self.id][id]:Invoke(...);
return result end

setmetatable(module.bf, methods);

-- RemoteEvent signal methods
if run_service:IsClient() then
  local connections = {};

  local function sync(self, id)
    if #connections ~= 0 then return nil end

    local folder = self.folder;

    local function signal_added(signal)
      local link = signals[self.id][signal.Name];
      local connection = if link and link.connection then signal.OnClientEvent:Connect(link.connection) else nil;
      signals[self.id][signal.Name] = {signal = signal, connection = connection};
    end

    local function signal_removed(signal)
      signals[self.id][signal.Name] = nil;

      local next = next;
      if not next(signals[self.id]) then
        for _, connection in ipairs(connections) do connection:Disconnect() end
        table.clear(connections);
      end
    end

    table.insert(connections, folder.ChildAdded:Connect(signal_added));
    table.insert(connections, folder.ChildRemoved:Connect(signal_removed));
    for _, signal in ipairs(folder:GetChildren()) do signal_added(signal) end
  return signals[self.id][id] end

  function module.re:fire(id:string, ...)
    (signals[self.id][id] or sync(self, id)).signal:FireServer(...);
  end

  function module.re:connect(id:string, procedure)
    local link = signals[self.id][id];
    if link and link.connection then error("signal "..id.." already exists") end
    if not (link or sync(self, id)) then signals[self.id][id] = {connection = procedure}; return end

    signals[self.id][id].connection = signals[self.id][id].signal.OnClientEvent:Connect(procedure);
  end

  function module.re:disconnect(id:string)
    local link = signals[self.id][id];
    if link.signal then link.connection:Disconnect() end
    signals[self.id][id].connection = nil;
  end
end

if run_service:IsServer() then
  function module.re:fire(id:string, player, ...)
    if not signals[self.id][id] then
      signals[self.id][id] = {signal = create_signal(self, id)};
    end

    signals[self.id][id].signal:FireClient(player, ...);
  end

  function module.re:connect(id:string, procedure:(Player, ...any) -> ())
    local link = signals[self.id][id];
    if link and link.connection then error("signal "..id.." already exists") end

    local signal:RemoteEvent = if link and link.signal then link.signal else create_signal(self, id);

    signals[self.id][id] = {signal = signal, connection = signal.OnServerEvent:Connect(procedure)};
  end

  function module.re:disconnect(id:string)
    signals[self.id][id].signal:Destroy();
    signals[self.id][id] = nil;
  end
end

-- RemoteFunction signal methods
if run_service:IsClient() then
  local connections = {};

  local function sync(self, id)
    if #connections ~= 0 then return nil end

    local folder = self.folder;

    local function signal_added(signal)
      signals[self.id][signal.Name] = signal;
    end

    local function signal_removed(signal)
      signals[self.id][signal.Name] = nil;

      local next = next;
      if not next(signals[self.id]) then
        for _, connection in ipairs(connections) do connection:Disconnect() end
        table.clear(connections);
      end
    end

    table.insert(connections, folder.ChildAdded:Connect(signal_added));
    table.insert(connections, folder.ChildRemoved:Connect(signal_removed));
    for _, signal in ipairs(folder:GetChildren()) do signal_added(signal) end
  return signals[self.id][id] end

  function module.rf:fire(id:string, ...)
    return (signals[self.id][id] or sync(self, id)):InvokeServer(...);
  end
end

if run_service:IsServer() then setmetatable(module.rf, methods) end

for id, category in pairs(module) do
  signals[id] = {};
  module[id].id = id;
  table.freeze(category);
end

table.freeze(signals);

return table.freeze(module)