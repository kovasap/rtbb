extends RigidBody2D

const min_speed = 880

var damage = 1

var stuck = false

# Disable collisions until the projectile has been alive for a bit to avoid colliding with the shooter.
func _ready():
  $CollisionShape2D.disabled = true

func _process(_delta):
  # If the projectile hits a certain minimum speed, it "hits the ground" and
  # not longer interacts with the world.
  if stuck:
    return
  if linear_velocity.length() < min_speed:
    $CollisionShape2D.disabled = true
    linear_velocity = Vector2(0, 0)
    $Sprite.modulate.a = 0.4
    stuck = true

func _on_AliveTimer_timeout():
  $CollisionShape2D.disabled = false
