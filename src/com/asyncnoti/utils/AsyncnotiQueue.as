/**
 * Created by urushev on 28.03.15.
 */
package com.asyncnoti.utils
{
public class AsyncnotiQueue
{
    // initialise the queue and offset
    private var queue:Array = [];
    private var offset:Number = 0;

    // Returns the length of the queue.
    public function getLength():Number
    {
        return (queue.length - offset);
    }

    // Returns true if the queue is empty, and false otherwise.
    public function isEmpty():Boolean
    {
        return (queue.length == 0);
    }

    /* Enqueues the specified item. The parameter is:
     *
     * item - the item to enqueue
     */
    public function enqueue(item:Object)
    {
        queue.push(item);
    }

    /* Dequeues an item and returns it. If the queue is empty, the value
     * 'undefined' is returned.
     */
    public function dequeue():Object
    {

        // if the queue is empty, return immediately
        if (queue.length == 0) return undefined;

        // store the item at the front of the queue
        var item = queue[offset];

        // increment the offset and remove the free space if necessary
        if (++offset * 2 >= queue.length)
        {
            queue = queue.slice(offset);
            offset = 0;
        }

        // return the dequeued item
        return item;

    }

    /* Returns the item at the front of the queue (without dequeuing it). If the
     * queue is empty then undefined is returned.
     */
    public function peek():Object
    {
        return (queue.length > 0 ? queue[offset] : undefined);
    }
}
}
