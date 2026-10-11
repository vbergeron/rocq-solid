//> using scala 3.9.0

// Runs the handler extracted from theories/Orders.v on an endless Kafka
// topic, with the consumer extracted from theories/Forever.v. Refunds.scala
// is written by demo/extract.sh.
import shop.refunds.Refunds.*

// An endless topic: a payment of 100, then the same refund of 30, delivered
// again and again; at-least-once delivery at its worst.
def topic(i: Int): Stream[Event] =
  RocqLazy(Cons0(if i == 0 then Paid(1, 100) else Refunded(2, 30), topic(i + 1)))

def take[A](n: Int, s: Stream[A]): scala.List[A] =
  if n == 0 then scala.Nil else hd(s) :: take(n - 1, tl(s))

@main def run(): Unit =
  for o <- take(6, states(empty)(topic(0))) do
    println(s"paid=${o.paid} refunded=${o.refunded}")
