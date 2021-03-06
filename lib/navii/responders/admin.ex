defmodule Navii.Responders.Admin do
  use Navii.Responder

  require Logger

  respond ~r/deploy now$/, msg do
    if is_admin?(msg.user) do
      Logger.warn "Deploying now..."
      System.cmd "curl", [Config.get_env(:navii, :deployhook)]
      send msg, "Yes, sir. (╭ರᴥ•́)"
    else
      Logger.warn "Loser trying to deploy..."
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  # kick <channel> <nick> :[reason]
  respond ~r/kick (#[^\s]+) ([^\s]+)(?: (.+))?$/, msg do
    if is_admin?(msg.user) do
      # matches
      channel = msg.matches[1]
      kickee = msg.matches[2]
      reason = ":" <> (msg.matches[3] || kickee)
      # chanserv
      pmsg = %{msg | room: "Chanserv"}
      # kick
      send pmsg, "op #{channel}"
      :timer.sleep(1000)
      command msg, Irc.Commands.kick!(channel, kickee, reason)
      :timer.sleep(1000)
      send pmsg, "deop #{channel}"
    else
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  # kickban <channel> <nick|pattern> [!P|!T <minutes>] [reason]
  respond ~r/kickban (#[^\s]+) ([^\s]+)(?: .+)?$/, msg do
    if is_admin?(msg.user) do
      # matches
      channel = msg.matches[1]
      kickee = msg.matches[2]
      opts = msg.matches[3] || ""
      # chanserv
      pmsg = %{msg | room: "Chanserv"}
      # kickban
      send pmsg, "op #{channel}"
      :timer.sleep(1000)
      send pmsg, "AKICK #{channel} ADD #{kickee}#{opts}"
      :timer.sleep(1000)
      send pmsg, "deop #{channel}"
    else
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  @doc """
  Check if the user is an admin.
  """
  @spec is_admin?(Hedwig.User.t | String.t) :: boolean
  def is_admin?(%{id: id}) do
    id
    |> String.split("@")
    |> Enum.at(0)
    |> is_admin?()
  end

  def is_admin?(user) when is_binary(user) do
    Config.get_env(:navii, :admins, "")
    |> String.split(",")
    |> Enum.any?(&String.equivalent?(&1, user))
  end
end
