//> using scala 3.9.0
// Refunds.scala uses pure function types, an experimental Scala feature.
//> using options -experimental

// Runs the handler extracted from theories/Orders.v, once on a list of
// events and once on an endless Kafka-like topic with the consumer
// extracted from theories/Forever.v. Refunds.scala is written by
// demo/extract.sh.
import shop.refunds.Refunds.*

// An endless topic: a payment of 100, then the same refund of 30, delivered
// again and again; at-least-once delivery at its worst.
def topic(i: Int): Stream[Event] =
  RocqLazy(Cons(if i == 0 then Paid(1, 100) else Refunded(2, 30), topic(i + 1)))

def take[A](n: Int, s: Stream[A]): List[A] =
  if n == 0 then Nil else hd(s) :: take(n - 1, tl(s))

@main def run(): Unit =
  // Refund 2 delivered twice, refund 3 more than what is left.
  val events = List(Paid(1, 100), Refunded(2, 30), Refunded(2, 30), Refunded(3, 90))
  println(s"replay: ${replay(events)}")
  for o <- take(5, states(empty)(topic(0))) do
    println(s"states: paid=${o.paid} refunded=${o.refunded}")
