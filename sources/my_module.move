module my_first_package::my_module {

  // 1. Imports
  use sui::object::{Self, UID};
  use sui::transfer; 
  use sui::tx_context::{Self, TxContext};

  // 2. Struct definitions
  struct Sword has key, store {
    id: UID,
    magic: u64,
    strength: u64,
  }

  struct Forge has key, store {
    id: UID,
    swords_created: u64,
  }

  // 3. Module initializer to be exucuted when this module is published
  fun init(ctx: &mut TxContext) {
    let admin = Forge {
      id: object::new(ctx),
      swords_created: 0,
    };

    // transfer the forge object to the module/package publisher
    transfer::transfer(admin, tx_context::sender(ctx));
  }

  // Part 4: Assessores required to read the struct attributes
  public fun magic(self: &Sword): u64 {
    self.magic
  }

  public fun strength(self: &Sword): u64 {
    self.strength
  }

  public fun swords_created(self: &Forge): u64 {
    self.swords_created
  }

  #[test]
  public fun test_sword_create() {
    use sui::transfer;

    // Create a dummy context for testing
    let ctx = tx_context::dummy();

    // Create a sword
    let sword = Sword {
      id: object::new(&mut ctx),
      magic: 42,
      strength: 7,
    };

    // Check if accessor functions return correct values
    assert!(magic(&sword) == 42 && strength(&sword) == 7, 1);

    // Create a dummy address and transfer the sword
    let dummy_address = @0xCAFE;
    transfer::transfer(sword, dummy_address);
  }

  // 5. Public/entry functions
  public fun create_sword(magic: u64, strength: u64, recipient: address, ctx: &mut TxContext) {
    use sui::transfer;

    // create a sword
    let sword = Sword {
      id: object::new(ctx),
      magic: magic,
      strength: strength,
    };

    // trasnfer the sword 
    transfer::transfer(sword, recipient);
  }

  #[test]
  fun test_sword_transactions() {
    use sui::test_scenario;

    // create test addresses reporesenting users
    let admin = @0xBABE;
    let initial_owner = @0xCAFE;
    let final_owner = @0xFACE;

    // first transaction to emulate module initialization
    let scenario_val = test_scenario::begin(admin);
    let scenario = &mut scenario_val;
    {
      init(test_scenario::ctx(scenario));
    };

    // second transaction executed by admin to create the sword
    test_scenario::next_tx(scenario, admin);
    {
      // create the sword and transfer it to the inistal owner
      create_sword(42, 7, initial_owner, test_scenario::ctx(scenario));
    };

    // thrid transaction executes by the initial sword owner
    test_scenario::next_tx(scenario, initial_owner);
    {
      // extract the sword owned by the initial owner
      let sword = test_scenario::take_from_sender<Sword>(scenario);
      // transfer the sword to the final owner
      sword_transfer(sword, final_owner, test_scenario::ctx(scenario))
    };

    // fourth transaction executed by the final sword owner
    test_scenario::next_tx(scenario, final_owner);
    {
      // extract the sword owned by the final owner 
      let sword = test_scenario::take_from_sender<Sword>(scenario);
      // verify that the sword has expected properties
      assert!(magic(&sword) == 42 && strength(&sword) == 7, 1);
      // return the sword to the object pool (it cannot be simply dropped)
      test_scenario::return_to_sender(scenario, sword)
    };

    test_scenario::end(scenario_val);
  }

  public fun sword_transfer(sword: Sword, recipient: address, _ctx: &mut TxContext) {
    use sui::transfer;

    // transfer the sword
    transfer::transfer(sword, recipient);
  }

  // 6. Private functions
}