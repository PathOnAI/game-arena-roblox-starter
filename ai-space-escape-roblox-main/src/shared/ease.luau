--!strict

local replicated_storage = game:GetService"ReplicatedStorage";
local user_input_service = game:GetService"UserInputService";

local module = {};

-- Creates a folder if one does not already exist and returns the existing one otherwise
function module.folder(source:Instance, name:string, ignore:boolean?):Folder
  local folder:Folder? = if ignore then nil else source:FindFirstChild(name);

  if not (folder and folder:IsA"Folder") then
    folder = Instance.new"Folder";
    folder.Name = name;
    folder.Parent = source;
  end
return folder end

-- Checks if a number is an integer
function module.is_int(n:number):boolean
return n==math.floor(n) end

-- Turns a string into Title Case ("This Is Title Case")
function module.title_case(text:string):string
  local title_case:string = text:gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end);
return title_case end

-- Rotates model into 4 possible directions
function module.rotate(instance:Model, r:number):CFrame
  local direction = {
    [0] = Vector3.FromNormalId(Enum.NormalId.Front),
    [3] = Vector3.FromNormalId(Enum.NormalId.Left),
    [2] = Vector3.FromNormalId(Enum.NormalId.Back),
    [1] = Vector3.FromNormalId(Enum.NormalId.Right)
  };

  local pivot_goal:CFrame = CFrame.lookAt(instance:GetPivot().Position, instance:GetPivot().Position+direction[r]);
return pivot_goal-pivot_goal.Position end

-- General function to raycast
function module.raycast(instances:any, length:number, parameters:RaycastParams?):RaycastResult
  local mouse:Vector2 = user_input_service:GetMouseLocation();
  local ray:Ray = workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y);

  if not parameters then
    parameters = RaycastParams.new();
    parameters.IgnoreWater = true;
    parameters.FilterType = Enum.RaycastFilterType.Whitelist;
    parameters.FilterDescendantsInstances = instances;
  end

  local raycast:RaycastResult = workspace:Raycast(ray.Origin, ray.Direction*length, parameters);
return raycast end

return table.freeze(module)