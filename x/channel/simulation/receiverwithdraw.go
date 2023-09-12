package simulation

import (
	"math/rand"

	"github.com/cosmos/cosmos-sdk/baseapp"
	sdk "github.com/cosmos/cosmos-sdk/types"
	simtypes "github.com/cosmos/cosmos-sdk/types/simulation"
	"github.com/dungtt-astra/astra/v3/x/channel/keeper"
	"github.com/dungtt-astra/astra/v3/x/channel/types"
)

func SimulateMsgReceiverwithdraw(
	ak types.AccountKeeper,
	bk types.BankKeeper,
	k keeper.Keeper,
) simtypes.Operation {
	return func(r *rand.Rand, app *baseapp.BaseApp, ctx sdk.Context, accs []simtypes.Account, chainID string,
	) (simtypes.OperationMsg, []simtypes.FutureOperation, error) {
		simAccount, _ := simtypes.RandomAcc(r, accs)
		msg := &types.MsgReceiverwithdraw{
			Creator: simAccount.Address.String(),
		}

		// TODO: Handling the Receiverwithdraw simulation

		return simtypes.NoOpMsg(types.ModuleName, msg.Type(), "Receiverwithdraw simulation not implemented"), nil, nil
	}
}
