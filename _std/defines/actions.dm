/// Internal flag that will always interrupt any action.
#define INTERRUPT_ALWAYS -1
/// Interrupted when object moves
#define INTERRUPT_MOVE 1
/// Interrupted when object does anything
#define INTERRUPT_ACT 2
/// Interrupted when object is attacked
#define INTERRUPT_ATTACKED 4
/// Interrupted when owner is stunned or knocked out etc.
#define INTERRUPT_STUNNED 8
/// Interrupted when another action is started.
#define INTERRUPT_ACTION 16

/// Action has not been started yet.
#define ACTIONSTATE_STOPPED (1<<0)
/// Action is in progress
#define ACTIONSTATE_RUNNING (1<<1)
/// Action was interrupted
#define ACTIONSTATE_INTERRUPTED (1<<2)
/// Action ended succesfully
#define ACTIONSTATE_ENDED (1<<3)
/// Action is ready to be deleted.
#define ACTIONSTATE_DELETE (1<<4)
/// Will finish action after next process.
#define ACTIONSTATE_FINISH (1<<5)
/// Will not finish unless interrupted.
#define ACTIONSTATE_INFINITE (1<<6)
