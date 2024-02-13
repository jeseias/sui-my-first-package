module my_first_package::my_module {

  // Imports
  use sui::object::{Self, UID};
  use sui::transfer; 
  use sui::tx_context::{Self, TxContext};

  // Struct definitions
  struct Sword has key, store {
    id: UID,
    magic: u64,
    strength: u64,
  }

  struct Forge has key, store {
    id: UID,
    swords_created: u64,
  }

  // Module initializer to be exucuted when this module is published
  fun init(ctx: &mut TxContext) {
    let admin = Forge {
      id: object::new(ctx),
      swords_created: 0,
    };

    // transfer the forge object to the module/package publisher
    transfer::transfer(admin, tx_context::sender(ctx));
  }

  // Assessores required to read the struct attributes
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
}